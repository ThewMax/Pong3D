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

        float4 _Color;
        float4 _Reflex;
        float _Gloss;
        sampler2D _MainTex;
        float4 _MainTex_ST;

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
            float4 _ShadowCoord : TEXCOORD3;
        };
    ENDCG

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            LOD 100
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase 

            float4 ComputeScreenPosit (float4 p)
            {
                float4 o = p * 0.5;
                return float4(float2(o.x, o.y*_ProjectionParams.x) + o.w, p.zw);
            }

            Interpolator vert (appdata v)
            {
                Interpolator o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.pos = mul( unity_ObjectToWorld, v.vertex);
                o._ShadowCoord = ComputeScreenPosit(o.vertex);
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

                return lerp(float4(ambientLight, 1), float4(ambientLight + _Reflex.y * diffuseLight + _Reflex.z * specularLight, 1), step(0.5, SHADOW_ATTENUATION(i)));
            }
            ENDCG
        }

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
