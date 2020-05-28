Shader "Custom/LCD"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Pixels("Pixels", Vector) = (101,10,0,0)
        _LCDTex("LCD (RGB)", 2D) = "white" {}
        _LCDTexPixels("LCD Pixels",  Vector) = (3,3,0,0)

        _DistanceOne ("Distance of full effect", Float) = 0.5 
        _DistanceZero ("Distance of zero effect", Float) = 1 

        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _LCDTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float4 _Pixels;
        float4 _LCDTexPixels;
        float _DistanceOne;
        float _DistanceZero;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        float rand(float x, float y){
			return frac(sin(x*12.9898 + y*78.233)*43758.5453);
		}

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            //clampinf the UV coords
            float2 uv = round(IN.uv_MainTex * _Pixels.xy + 0.5) / _Pixels.xy;
            fixed4 c = tex2D (_MainTex, uv) * _Color;

            float2 uv_lcd = IN.uv_MainTex * _Pixels.xy / _LCDTexPixels;
            fixed4 lcd_color = tex2D(_LCDTex, uv_lcd);

            float dist = distance(_WorldSpaceCameraPos, IN.worldPos);
            float alpha = saturate((dist - _DistanceOne) / (_DistanceZero - _DistanceOne));

            //should help with repeating patterns
            float2 uv_glitch = IN.uv_MainTex.xy / _Pixels.xy;
            uv_glitch *= 3;
            uv_glitch = frac(uv_glitch);

            o.Albedo = lerp(c * lcd_color, c, alpha);
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = 1;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
