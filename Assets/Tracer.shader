Shader "Unlit/Tracer"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Reflex ("Reflection", Vector) = (0.25,0.5,0.25)
        _Gloss ("Gloss", float) = 1.0
    }

    CGINCLUDE
        #include "UnityCG.cginc"
        #include "Lighting.cginc"
        #include "AutoLight.cginc"

        float4 _Color; // Instanciando a variável de cor
        float4 _Reflex; // Variavel com os coeficientes de cor ambiente, difusa e especular
        float _Gloss; // Quão glossy deve ser, para o expoente da especularidade
        sampler2D _MainTex; // Textura (só é usada no calculo do Shadow Mapping)
        float4 _MainTex_ST; // Textura

        // Estrutura de dados recebida da geometria
        struct appdata
        {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float2 uv : TEXCOORD0;
        };

        // Estrutura de dados em que o Vertex shader poe as informações
        // interpoladas pra cada ponto, para o Pixel Shader
        struct Interpolator
        {
            float4 vertex : SV_POSITION;
            float2 uv : TEXCOORD0;
            float3 normal : TEXCOORD1;
            float4 pos : TEXCOORD2;
            float4 _ShadowCoord : TEXCOORD3;
        };
    ENDCG

    SubShader
    {
        // Especifica que o objeto é opaco
        Tags { "RenderType"="Opaque" }

        // Primeira passagem de CG
        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            LOD 100
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase 

            // Essa função usa a posição atual do ponto para calcular se há uma sombra projetada aqui
            // Funcionamento meio obscuro, encontrada em: https://forum.unity.com/threads/how-to-make-unlit-shader-that-casts-shadow.646246/
            float4 ComputeScreenPosit (float4 p)
            {
                float4 o = p * 0.5;
                return float4(float2(o.x, o.y*_ProjectionParams.x) + o.w, p.zw);
            }

            // Aqui o Vertex Shader
            Interpolator vert (appdata v)
            {
                Interpolator o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Coloca a posição do vértice em coordenadas de observador
                o.uv = TRANSFORM_TEX(v.uv, _MainTex); // Transforma a textura, que é usada para as sombras
                o.normal = UnityObjectToWorldNormal(v.normal); // Normal do objeto é convertida para mundo
                o.pos = mul( unity_ObjectToWorld, v.vertex); // Posição do objeto em coordenadas mundo
                o._ShadowCoord = ComputeScreenPosit(o.vertex); // Coordenadas de sombra
                return o;
            }

            // Pixel Shader
            float4 frag (Interpolator i) : SV_Target
            {

                float4 lightColor = _LightColor0; // Instancia a cor da luz

                // Cor ambiente do objeto
                float3 ambientLight = _Reflex.x * _Color; // Coeficiente vezes cor difusa

                // Calculo da cor difusa
                float3 N = normalize(i.normal); // Normaliza o vetor normal para garantir que está normalizado e teremos suavidade no polígono
                float3 L = _WorldSpaceLightPos0.xyz; // Posição da luz em coordenadas de mundo
                
                // Cor difusa vezes cosseno da normal e da incidência da luz, como são versores, não precisa dividir pela magnitude
                // O saturate serve pra colocar o valor final num espaço de 0 a 1, pois a cor pode "estourar"
                float3 diffuseLight = saturate(dot(N,L) * _Color); 

                // Calculo da cor especular
                float3 V = normalize(_WorldSpaceCameraPos - i.pos); // Pega posição do observador e encontra vetor de observação
                float3 R = reflect( -L, N); // Calculo rápido para o vetor de reflexão da luz

                // Cor especular, cosseno da observação e reflexão, que são versores, elevado ao gloss 
                float3 specularLight = pow( dot(V, R), _Gloss );
                specularLight = saturate(specularLight * lightColor); // Multiplica o cosseno pela cor da luz e coloca entre 0 e 1

                // Retorna como cor a luz ambiente ou o cálculo total da luz com os coeficientes de reflexão
                // Depende da coordenada estar em uma sombra ou não, garantimso um ou outro via função "step"
                return lerp(float4(ambientLight, 1), float4(ambientLight + _Reflex.y * diffuseLight + _Reflex.z * specularLight, 1), step(0.5, SHADOW_ATTENUATION(i)));
            }
            ENDCG
        }

        // Segunda passagem de Cg, faz o Shadow Casting, é automática
        // Então os retornos das funç~eos são minimizados, pois devem existir
        // Vertex e Pixel Shader para funcionar. Também descobrimos que precisavamos defini-la em: https://forum.unity.com/threads/how-to-make-unlit-shader-that-casts-shadow.646246/
        Pass
        {
            Tags {"LightMode" = "ShadowCaster"}
            LOD 80

            CGPROGRAM
            #pragma vertex vertShadow
            #pragma fragment fragShadow

            float4 vertShadow(appdata v) : SV_POSITION
            {
                return UnityObjectToClipPos(v.vertex);
            }

            float4 fragShadow(float4 i:SV_POSITION): SV_Target
            {
                return 0;
            }
            ENDCG
        }
        
    }
}
