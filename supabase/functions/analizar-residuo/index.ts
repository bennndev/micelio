import { GoogleGenerativeAI, Schema, Type } from "npm:@google/generative-ai";

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
      throw new Error(`Failed to fetch image: ${imageResp.statusText}`);
    }
    const arrayBuffer = await imageResp.arrayBuffer();
    const base64Image = btoa(
      new Uint8Array(arrayBuffer).reduce((data, byte) => data + String.fromCharCode(byte), '')
    );
    const mimeType = imageResp.headers.get('content-type') || 'image/jpeg';

    // 2. Initialize Gemini
    const apiKey = Deno.env.get('GEMINI_API_KEY');
    if (!apiKey) {
      throw new Error("Missing GEMINI_API_KEY environment variable");
    }
    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

    // 3. Define the structured output schema
    const residuoSchema: Schema = {
      type: Type.OBJECT,
      properties: {
        tipo: { 
          type: Type.STRING, 
          description: "Nombre específico del residuo, ej. 'Botella de agua sin etiqueta', 'Caja de pizza'" 
        },
        material: { 
          type: Type.STRING, 
          description: "Material predominante. EXACTAMENTE uno de: plástico, vidrio, papel, cartón, orgánico, metal, otro" 
        },
        reciclable: { 
          type: Type.BOOLEAN, 
          description: "True si el material es reciclable en un contexto urbano estándar" 
        },
        contenedor: { 
          type: Type.STRING, 
          description: "Color del contenedor recomendado. EXACTAMENTE uno de: Amarillo, Azul, Verde, Marrón, Gris" 
        },
        peso_estimado_kg: { 
          type: Type.NUMBER, 
          description: "Peso estimado realista en kilogramos del residuo (ej. 0.05)" 
        },
        co2_ahorrado_kg: { 
          type: Type.NUMBER, 
          description: "Estimación conservadora de CO2 evitado si se recicla (en kg)" 
        },
        confianza: { 
          type: Type.NUMBER, 
          description: "Nivel de confianza de la predicción, número decimal entre 0.0 y 1.0" 
        },
        instrucciones: { 
          type: Type.STRING, 
          description: "Breves instrucciones útiles de cómo preparar y depositar el residuo" 
        }
      },
      required: ["tipo", "material", "reciclable", "contenedor", "peso_estimado_kg", "co2_ahorrado_kg", "confianza", "instrucciones"],
    };

    // 4. Call Gemini API
    const prompt = "Analiza esta imagen y clasifica el residuo que aparece de acuerdo al esquema JSON estructurado proporcionado.";
    const result = await model.generateContent({
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
    });

    const responseText = result.response.text();
    const structuredData = JSON.parse(responseText);

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
