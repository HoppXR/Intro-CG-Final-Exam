# Intro CG Final Exam

### What was implemented

- Vertex Coloring
- Outlining
- Color Tint
- Color correction

### Where was it implemented

Vertex coloring, outlining, and color tint was combined into a single shader and applied onto the tiles in the game scene. Color correction was applied to the camera, and the LUT was edited in photoshop.

### How was it implemented

The vertex color shader was combined with the outline shader. This was done by appling the vertex color shader to the extruded vertices in the outline shader pass. The first step with the outline shader is to cull the front facing vertices, then vertices are extruded by the vertex shader by calculating the normals and offset from view direction, then applying these values to the vertex postion. 
After the vertices have been extruded, they are colored using the r, g, and b values in the x, -y, and -z directions respectively, The positions of the colors have been modified using addition and division to manipulate the strength of the color projected onto the object. Since the vertex color shader was done inside of the outline shader pass, the outline color will take in the vertex color shader values, resulting in the vertex colored outline.

The Vertex shader for both outline shader and vertex color shader can be seen below.

``` ShaderLab
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
```

The color tint shader was also implemented inside of the vertex color and outline shader, but the difference is that the color tint shader is excecuted inside of the subshader in its own cg program instead of the pass. 
The color tint shader uses the built in Unity Lambert surface shader, and multiplies the color tint by the already existing color of the object, just like making a layer of color on top of the original color layer.

The color tint cg program inside of the outline and vertex color shader can be seen below.

``` ShaderLab
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
```

The color grade shader 
