const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req: Request) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { imageUrl } = await req.json();

    if (!imageUrl) {
      throw new Error("Missing 'imageUrl' parameter");
    }

    // 1. Download image and convert to base64 inlineData
    const imageResp = await fetch(imageUrl);
    if (!imageResp.ok) {
      throw new Error(`Failed to fetch image from Storage: ${imageResp.statusText}`);
    }
    const arrayBuffer = await imageResp.arrayBuffer();
    const base64Image = btoa(
      new Uint8Array(arrayBuffer).reduce((data, byte) => data + String.fromCharCode(byte), '')
    );
    const mimeType = imageResp.headers.get('content-type') || 'image/jpeg';

    // 2. Initialize Gemini API via native Fetch REST
    const apiKey = Deno.env.get('GEMINI_API_KEY');
    if (!apiKey) {
      throw new Error("Missing GEMINI_API_KEY environment variable");
    }

    // 3. Define the structured output schema (OpenAPI 3.0 representation)
    const residuoSchema = {
      type: "object",
      properties: {
        tipo: { 
          type: "string", 
          description: "Nombre específico del residuo, ej. 'Botella de agua sin etiqueta', 'Caja de pizza'" 
        },
        material: { 
          type: "string", 
          description: "Material predominante. EXACTAMENTE uno de: plástico, vidrio, papel, cartón, orgánico, metal, otro" 
        },
        reciclable: { 
          type: "boolean", 
          description: "True si el material es reciclable en un contexto urbano estándar" 
        },
        contenedor: { 
          type: "string", 
          description: "Color del contenedor recomendado. EXACTAMENTE uno de: Amarillo, Azul, Verde, Marrón, Gris" 
        },
        peso_estimado_kg: { 
          type: "number", 
          description: "Peso estimado realista en kilogramos del residuo (ej. 0.05)" 
        },
        co2_ahorrado_kg: { 
          type: "number", 
          description: "Estimación conservadora de CO2 evitado si se recicla (en kg)" 
        },
        confianza: { 
          type: "number", 
          description: "Nivel de confianza de la predicción, número decimal entre 0.0 y 1.0" 
        },
        instrucciones: { 
          type: "string", 
          description: "Breves instrucciones útiles de cómo preparar y depositar el residuo" 
        }
      },
      required: ["tipo", "material", "reciclable", "contenedor", "peso_estimado_kg", "co2_ahorrado_kg", "confianza", "instrucciones"],
    };

    const prompt = "Analiza esta imagen y clasifica el residuo que aparece de acuerdo al esquema JSON estructurado proporcionado.";

    // Call Gemini API using native fetch
    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=${apiKey}`;
    
    const geminiResp = await fetch(geminiUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        contents: [{
          role: "user",
          parts: [
            { text: prompt },
            { inlineData: { data: base64Image, mimeType: mimeType } }
          ]
        }],
        generationConfig: {
          responseMimeType: "application/json",
          responseSchema: residuoSchema,
        },
      }),
    });

    if (!geminiResp.ok) {
      const errorText = await geminiResp.text();
      throw new Error(`Gemini API Error: ${geminiResp.status} - ${errorText}`);
    }

    const geminiData = await geminiResp.json();
    
    // Extract the text content containing the JSON string
    const textResponse = geminiData.candidates?.[0]?.content?.parts?.[0]?.text;
    if (!textResponse) {
      throw new Error("No response content from Gemini API");
    }

    const structuredData = JSON.parse(textResponse);

    return new Response(
      JSON.stringify(structuredData),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : "Unknown error";
    return new Response(
      JSON.stringify({ error: errorMessage }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 },
    );
  }
});
