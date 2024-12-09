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

The color grade shader takes in a LUT (look up table) and a float range between 0 and 1 that determines how strong the LUT is effecting the screen. The first thing in the color grade shader is turning off culling and depth to make sure the effect is shown on the screen. Then the amount of colors in the LUT is defined. Inside of the fragment shader the size of the LUT is calculated to avoid going beyond the LUT limit, the offsets are calculated to map the image to the LUT, then the color grading value is returned. Finally a C# script is used to project the material that has the shader applied to it to project it on the screen.

The color grading fragment shader can be seen below.

``` ShaderLab
fixed4 frag (v2f i) : SV_Target
{
    float maxColor = COLORS - 1.0; // Value of colors - 1
    fixed4 col = saturate(tex2D(_MainTex, i.uv));
    float halfColX = 0.5 / _LUT_TexelSize.z;
    float halfColY = 0.5 / _LUT_TexelSize.w;
    float threshold = maxColor / COLORS;

    float xOffset = halfColX + col.r * threshold / COLORS;
    float yOffset = halfColY + col.g * threshold;
    float cell = floor(col.b * maxColor);

    float2 lutPos = float2(cell / COLORS + xOffset, yOffset);
    float4 gradedCol = tex2D(_LUT, lutPos);

    return lerp(col, gradedCol, _Contribution);
}
```

### Why was it done

I think adding colored vertexes to the outline shader made the object look more appealing compared to just a regular black outline and makes the visual style more unique.

Color tint was added to tint the base color of the objects, so it would not look as plain.

Color correction was used to visually enhance the look of the final game, and making it look different and unique.
