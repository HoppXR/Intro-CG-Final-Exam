Shader "HoppXR/Outline Vertex Color Tint"
{
    Properties
    {
        _ColorTint ("Tint", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _Outline ("Outline Width", Range (0.002, 0.5)) = 0.005
    }
    
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        
        CGPROGRAM
            #pragma surface surf Lambert finalcolor:myColor
            struct Input
            {
                float2 uv_MainTex;
            };

            sampler2D _MainTex;
            fixed4 _ColorTint;

            void myColor (Input IN, SurfaceOutput o, inout fixed4 color)
            {
                color *= _ColorTint;
            }
            
            void surf (Input IN, inout SurfaceOutput o)
            {
                o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
            }
        ENDCG
        
        Pass
        {
            Cull Front
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 color : COLOR;
            };

            float _Outline;
            float4 _OutlineColor;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                float3 norm = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));
                float2 offset = TransformViewToProjection(norm.xy);

                o.pos.xy += offset * o.pos.z * _Outline;
                
                o.color.r = (v.vertex.x + 5) / 6;
                o.color.g = (-v.vertex.y + 3) / 5;
                o.color.b = (-v.vertex.x + 4) / 5;

                return o;
            }
            fixed4 frag(v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
