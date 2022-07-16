Shader "Unlit/Tracer"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Reflex ("Reflection", Vector) = (0.25,0.5,0.25)
        _Gloss ("Gloss", float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase 

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct Interpolator
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float4 pos : TEXCOORD2;
            };

            float4 _Color;
            float4 _Reflex;
            float _Gloss;

            Interpolator vert (appdata v)
            {
                Interpolator o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.pos = mul( unity_ObjectToWorld, v.vertex);
                return o;
            }

            float4 frag (Interpolator i) : SV_Target
            {

                float4 lightColor = _LightColor0;

                //ambient lighing
                float3 ambientLight = _Reflex.x * _Color;

                // difusse lighting
                float3 N = normalize(i.normal);
                float3 L = _WorldSpaceLightPos0.xyz;
                
                float3 diffuseLight = saturate(dot(N,L) * _Color);

                //specular lighting
                float3 V = normalize(_WorldSpaceCameraPos - i.pos);
                float3 R = reflect( -L, N);
                float3 specularLight = saturate(dot(V, R) * lightColor);
                specularLight = pow( specularLight, _Gloss);

                return float4(ambientLight + _Reflex.y * diffuseLight + _Reflex.z * specularLight, 1);
            }
            ENDCG
        }

        Pass
        {
            Tags {"LightMode" = "ShadowCaster"}

            CGPROGRAM
            #pragma vertex vertShadow
            #pragma fragment fragShadow

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2fShadow {
                V2F_SHADOW_CASTER;
                UNITY_VERTEX_OUTPUT_STEREO
            };
        
            v2fShadow vertShadow( appdata v )
            {
                v2fShadow o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }
        
            float4 fragShadow( v2fShadow i ) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }

            // struct Interpolator
            // {
            //     float2 uv : TEXCOORD0;
            //     float4 vertex : SV_POSITION;
            //     float3 normal : TEXCOORD1;
            //     float4 pos : TEXCOORD2;
            // };

            // Interpolator vertShadow(appdata v) : SV_POSITION
            // {
            //     Interpolator o;
            //     o.vertex = UnityObjectToClipPos(v.vertex);
            //     //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            //     o.normal = UnityObjectToWorldNormal(v.normal);
            //     o.pos = mul( unity_ObjectToWorld, v.vertex);
            //     return o;
            // }

            // float4 fragShadow(Interpolator i): SV_Target
            // {
            //     return 0;
            // }
            ENDCG
        }
        
    }
}
