Shader "Custom/marbletest"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _UseScreenAspectRatio ("Aspect", int) = 1
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

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
        int _UseScreenAspectRatio;

        float2 screen_aspect(float2 uv)
        {
            if (_UseScreenAspectRatio == 0)
                return uv;

            uv.x -= 0.5;
            uv.x *= _ScreenParams.x / _ScreenParams.y;
            uv.x += 0.5;
            return uv;
        }


        float2 random2(float2 st)
            {
                st = float2(dot(st, float2(127.1, 311.7)),
                            dot(st, float2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            IN.uv_MainTex = screen_aspect(IN.uv_MainTex);

            float2 st = IN.uv_MainTex;
            st *= 3;

            float2 ist = floor(st);
            float2 fst = frac(st);

            float distance = 5;

            for (int y = -1; y <= 1; y++)
            for (int x = -1; x <= 1; x++)
            {
                float2 neighbor = float2(x,y);
                float2 p = 0.5+0.5 * sin(_Time.y + 6.2831 * random2(ist + neighbor));

                float2 diff = neighbor + p - fst;
                distance = min(distance, distance * length(diff) * length(diff));
            }

            float4 color =(step(0.1, abs(0.3 - smoothstep(0, 0.03, distance))), step(0.1, abs(0.9 - smoothstep(0, 0.13, distance))), step(0.1, abs(0.7 - smoothstep(0, 0.07, distance))), 0);
            // Albedo comes from a texture tinted by color
            o.Albedo = color.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = color.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
