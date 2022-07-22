Shader "Unlit/speedy"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        // Aqui dizemos para a pipeline que o objeto é transparente
        // Portanto, deve ser um dos últimos na fila de renderização
        Tags { "RenderType"="Transparent"
                "Queue" = "Transparent" }

        Pass
        {
            // Ele não deve escrever no Z-buffer
            ZWrite Off
            // E deve ocorrer um Blend da sua cor com a já renderizada no pixel
            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            // Estrutura de dados com os vértices e coordenadas
            // de textura que vem da geometria
            // (Embora não usamos textura, estou usando a coordenada
            // de mapeamento)
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            // Estrutura que o Vertex Shader retorna pra o Fragmente/pixel Shader
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // Aqui instanciamos no CG a variável com a cor do material
            float4 _Color;

            // Vertex Shader
            v2f vert (appdata v)
            {
                v2f o;
                // Convertendo as coordenadas do vértice do objeto para coordenada
                // de observador, usando a camera
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // Estamos calculando a cor do ponto usando
                // a Cor multiplicada pela coordenada de textura no eixo X
                // Como o Blend é aditivo, as cores são somadas, e quando mais
                // perto do 1 na coordenada de textura x estamos no cone, menos cor é somada.
                float4 col = (1-i.uv.x) * _Color;
                return col;
            }
            ENDCG
        }
    }
}
