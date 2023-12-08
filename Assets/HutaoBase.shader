Shader "Unlit/Hutao"
{
    Properties
    {
        _AmbientColor ("Ambient Color", Color) = (0.5,0.5,0.5)
        _DiffuseColor ("Diffuse Color", Color) = (0.9,0.9,0.9)
        _ShadowColor ("Shadow Color", Color) = (0.9,0.9,0.9)
        
        _BaseTexFac ("Base Tex Fac", Range(0,1)) = 1
        _BaseTex ("Base Tex", 2D) = "white" {}
        _ToonTexFac ("Toon Tex Fac", Range(0,1)) = 1
        _ToonTex ("Toon Tex", 2D) = "white" {}
        _SphereTexFac ("Sphere Tex Fac", Range(0,1)) = 0
        _SphereTex ("Sphere Tex", 2D) = "white" {}
        _SphereMulAdd ("Sphere Mul/Add", Range(0,1)) = 0

        _DoubleSided ("Double Sided", Range(0,1)) = 0
        _Alpha ("Alpha", Range(0,1)) = 1

        _MainTex ("Texture", 2D) = "white" {}

        _MetalTex("Metal Tex", 2D) = "black" {}
        
        _SpecExpon("Spec Exponent", Range(1,128)) = 50
        _KsNonMetallic ("Ks Non-metallic", Range(0,3)) = 1
        _KsMetallic ("Ks Metallic", Range(0,3)) = 1

        _NormalMap ("Normal Map", 2D) = "bump" {}
        _ILM ("ILM", 2D)  = "black" {}

        _RampTex ("Ramp Tex", 2D) = "white" {}

        _RampMapRow0("Ramp Map Row 0", Range(1,5)) = 4      //1      //4
        _RampMapRow1("Ramp Map Row 1", Range(1,5)) = 3      //4      //3
        _RampMapRow2("Ramp Map Row 2", Range(1,5)) = 1      //3      //1
        _RampMapRow3("Ramp Map Row 3", Range(1,5)) = 5      //5      //5
        _RampMapRow4("Ramp Map Row 4", Range(1,5)) = 2      //2      //1

        _ShadowOffset("Shadow Offset0",Range(0,1)) = 0.423
        _ShadowOffset1("Shadow Offset1",Range(0,1)) = 0.45
        _ShadowSmoothness("Shadow Smoothness0",Range(0,1)) = 0

        _OutlineOffset("Outline Offset", Float) = 0.000015

        _OutlineMapColor0 ("Outline Map Color 0", Color) = (0,0,0,0)
        _OutlineMapColor1 ("Outline Map Color 1", Color) = (0,0,0,0)
        _OutlineMapColor2 ("Outline Map Color 2", Color) = (0,0,0,0)
        _OutlineMapColor3 ("Outline Map Color 3", Color) = (0,0,0,0)
        _OutlineMapColor4 ("Outline Map Color 4", Color) = (0,0,0,0)

  
    }
    SubShader
    {
        //Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Name "ShadowCaster"
            Tags {"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull off

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            //----------------------
            //Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHINESS_TEXTURE_ALBEDO_CHANNEL_A

            //-----------------------
            //GPU Instancing 
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            //------------------------
            //Universal Pipeline keywords

            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL

        }


        Pass
        {
            Name "DepthNormals"
            Tags{"LightMode"="DepthNormals"}

            ZWrite On
            Cull off

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthNormalsVertex
	        #pragma fragment DepthNormalsFragment

            //----------------------------------------
            //Material Keywords 
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _PARALLAXMAP
            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHINESS_TEXTURE_ALBEDO_CHANNEL_A

            //------------------------------------------
            //GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthNormalsPass.hlsl"
            ENDHLSL
        }


        Pass
        {
            Name "DrawObject"
            Tags {
                "RenderPipeline" = "UniversalPipeline"
                "RenderType" = "Opaque"
                "RenderType" = "Transparent"
                "LightMode" = "UniversalForward"
            }
            LOD 100
            Cull Off

            HLSLPROGRAM
            #pragma multi_compile _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _SHADOWS_SOFT

            #pragma vertex vert 
            #pragma fragment frag 

            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            struct appdata{
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                half3 normal : NORMAL;
                half4 tangent : TANGENT;
                half4 color : COLOR0;     
            };
            
            struct v2f {
                float2 uv: TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 positionVS : TEXCOORD2;
                float4 positionCS : SV_POSITION;
                float4 positionNDC : TEXCOORD3;
                float3 normalWS : TEXCOORD4;
                float3 tangentWS : TEXCOORD5;
                float3 bitangentWS : TEXCOORD6;
                float fogCoord: TEXCOORD7;
                float4 shadowCoord : TEXCOORD8;


            };

            CBUFFER_START(UnityPerMaterial)
            float4 _AmbientColor;
            float4 _DiffuseColor;
            float4 _ShadowColor;

            half _BaseTexFac;
            sampler2D _BaseTex;
            sampler2D _SkinTex;
            float4 _BaseTex_ST;
            half _ToonTexFac;
            sampler2D _ToonTex;
            half _SphereTexFac;
            sampler2D _SphereTex;
            half _SphereMulAdd;

            half _DoubleSided;
            half _Alpha;

            sampler2D _MetalTex;


            float _SpecExpon;
            float _KsNonMetallic;
            float _KsMetallic;

            sampler2D _NormalMap;
            sampler2D _ILM;

            sampler2D _RampTex;
            half    _ShadowOffset;
            half    _ShadowOffset1;
            half    _ShadowSmoothness;

            float _RampMapRow0;
            float _RampMapRow1;
            float _RampMapRow2;
            float _RampMapRow3;
            float _RampMapRow4;

            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _BaseTex);
                o.positionWS = vertexInput.positionWS;
                o.positionVS = vertexInput.positionVS;
                o.positionCS = vertexInput.positionCS;
                o.positionNDC = vertexInput.positionNDC;

                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(v.normal,v.tangent);
                o.tangentWS = vertexNormalInput.tangentWS;
                o.bitangentWS = vertexNormalInput.bitangentWS;
                o.normalWS = vertexNormalInput.normalWS;
 
                o.fogCoord = ComputeFogFactor(vertexInput.positionCS.z);

                o.shadowCoord = TransformWorldToShadowCoord(vertexInput.positionWS);
                return o;

            }

            float4 frag (v2f i, bool IsFacing : sv_IsFrontFace) : SV_Target{
                
                // Light light = GetMainLight(i.shadowCoord);
                // float NoL = dot(normalize(i.normalWS), normalize(light.direction));
                // float lambert = max(0, NoL);
                // float halfLambert = pow(lambert * 0.5 + 0.5, 2);
                // float4 baseTex = tex2D(_BaseTex,i.uv);
                // float4 finalColor = float4(baseTex.r,baseTex.g,baseTex.b,1);
                // float3 albedo = baseTex.rgb * halfLambert;
                // float alpha = baseTex.a * _Alpha;
                // float4 col = float4(albedo, alpha);
                // clip(col.a - 0.5);
                // col.rgb = MixFog(col.rgb, i.fogCoord);

                Light light = GetMainLight(i.shadowCoord);
                float4 normalMap = tex2D(_NormalMap, i.uv);
                float3 N = i.normalWS;
                #if _NormalMap
                    float3 normalTS = float3(normalMap.ag * 2 - 1 , 0);
                    normalTS.z = sqrt(1-dot(normalTS.xy, normalTS.xy));
                    float3 N = normalize(mul(normalTS, float3x3(i.tangentWS, i.bitangentWS, i.normalWS)))
                #endif
  


                // half3 N = SafeNormalize(i.normalWS);
                
                float3 V = normalize(mul((float3x3)UNITY_MATRIX_I_V, i.positionVS * (-1)));
                float3 L = normalize(light.direction);
                float3 H = normalize(L+V);

                float NoL = dot(N,L);
                float NoH = dot(N,H);
                float NoV = dot(N,V);

                
                half3 normalVS = normalize(mul((float3x3)UNITY_MATRIX_V,N)); //归一化的观察空间法线
                float2 matcapUV = normalVS.xy * 0.5 + 0.5;
                // float2 matcapUV = normalVS.xy*0.5+0.5;
                

                float4 baseTex = tex2D(_BaseTex, i.uv);
                float4 toonTex = tex2D(_ToonTex, matcapUV);
                float4 sphereTex = tex2D(_SphereTex, matcapUV);
                float3 ambientColor = _AmbientColor.rgb;
                
                float3 baseColor = saturate(lerp(ambientColor, ambientColor * baseTex.rgb  , _BaseTexFac));
                // baseColor = saturate(lerp(baseColor, baseColor+ _DiffuseColor.rgb,0.6));
                // baseColor = lerp(baseColor,baseColor*baseTex.rgb, _BaseTexFac);
                baseColor = lerp(baseColor,baseColor*toonTex.rgb, _ToonTexFac);
                baseColor = lerp(lerp(baseColor,baseColor*sphereTex.rgb,_SphereTexFac), lerp(baseColor, baseColor+sphereTex.rgb, _SphereTexFac), _SphereMulAdd);

                float4 ilm = tex2D(_ILM, i.uv);

                float matEnum0 = 0.0;
                float matEnum1 = 0.3;
                float matEnum2 = 0.5;
                float matEnum3 = 0.7;
                float matEnum4 = 1.0;

                float ramp0 = _RampMapRow0/10.0-0.05; //4
                float ramp1 = _RampMapRow1/10.0-0.05; //3
                float ramp2 = _RampMapRow2/10.0-0.05; //1
                float ramp3 = _RampMapRow3/10.0-0.05; //5
                float ramp4 = _RampMapRow4/10.0-0.05; //2
                // int index = 4;
                // index = lerp(index, 1, step(0.2, ilm.a));
                // index = lerp(index, 2, step(0.4, ilm.a));
                // index = lerp(index, 0, step(0.6, ilm.a));
                // index = lerp(index, 3, step(0.8, ilm.a));

                float dayRampV = lerp(ramp4, ramp3, step(ilm.a, (matEnum3 + matEnum4)/2));
                dayRampV = lerp(dayRampV, ramp2, step(ilm.a, (matEnum2 + matEnum3)/2));
                dayRampV = lerp(dayRampV, ramp1, step(ilm.a, (matEnum1 + matEnum2)/2));
                dayRampV = lerp(dayRampV, ramp0, step(ilm.a, (matEnum0 + matEnum1)/2));
                float nightRampV = dayRampV + 0.5;

                float lambert = max(0,NoL);          
                float halflambert = pow(lambert * 0.5+ 0.5 , 2);
                float lambertStep = smoothstep(_ShadowOffset, _ShadowOffset1, halflambert);

                //halflambert = 0.0;

                float rampClampMin =0.003;
                float rampClampMax =0.997;
                float isDay = (L.y +1)/2;

                float smoothLambert = smoothstep(0, _ShadowSmoothness, halflambert);
                float rampGrayU = clamp(smoothLambert,rampClampMin,rampClampMax);
                float2  rampGrayDayUV = float2(rampGrayU, 1-dayRampV);
                float2  rampGrayNightUV = float2(rampGrayU, 1-nightRampV);
                float3 grayRamp = tex2D(_RampTex, rampGrayDayUV);

                float rampDarkU = rampClampMin;
                float2 rampDarkDayUV = float2(rampDarkU, 1- dayRampV);
                float2 rampDarkNightUV = float2(rampDarkU, 1- nightRampV);

                float3 rampGrayColor = lerp(tex2D(_RampTex, rampGrayNightUV).rgb, tex2D(_RampTex, rampGrayDayUV).rgb, isDay);
                float3 rampDarkColor = lerp(tex2D(_RampTex, rampDarkNightUV).rgb, tex2D(_RampTex, rampDarkDayUV).rgb, isDay);

                float3 grayShadowColor = baseColor * rampGrayColor * _ShadowColor.rgb;
                float3 darkShadowColor = baseColor * rampDarkColor * _ShadowColor.rgb;

                float3 diffuse = 0;

                diffuse = lerp(grayShadowColor, baseColor, lambertStep );
                diffuse = lerp(darkShadowColor, diffuse, saturate(ilm.g * 2));
                diffuse = lerp(diffuse, baseColor, saturate(ilm.g-0.5)* 2);

                float blinnPhong = step(0, NoL )* pow(max(0,NoH), _SpecExpon);
                
                float3 nonMetallicSpec = step(1.04-blinnPhong, ilm.b) * ilm.r * _KsNonMetallic; 
                float3 metallicSpec = blinnPhong * ilm.b * (lambertStep*0.8+0.2) * baseColor * _KsMetallic;
            

                float isMetal = step(0.95, ilm.r);

                float3 specular = lerp(nonMetallicSpec, metallicSpec, isMetal);

                float3 metallic = lerp(0,tex2D(_MetalTex, matcapUV).r * baseColor, isMetal);

                float3 albedo = diffuse + specular + metallic;

                float alpha = _Alpha * baseTex.a * toonTex.a * sphereTex.a; 
                alpha = saturate(min(max(IsFacing, _DoubleSided), alpha));
                
                float4 col = float4(albedo, alpha);

                // clip(col.a - 0.5);
                
                col.rgb = MixFog(col.rgb, i.fogCoord);
                
                // return float4(nonMetallicSpec, 1);
                return col;

            }

            

            ENDHLSL
        }


        // Pass
        // {
        //     CGPROGRAM
        //     #pragma vertex vert
        //     #pragma fragment frag
        //     // make fog work
        //     #pragma multi_compile_fog

        //     #include "UnityCG.cginc"

        //     struct appdata
        //     {
        //         float4 vertex : POSITION;
        //         float2 uv : TEXCOORD0;
        //     };

        //     struct v2f
        //     {
        //         float2 uv : TEXCOORD0;
        //         UNITY_FOG_COORDS(1)
        //         float4 vertex : SV_POSITION;
        //     };

        //     sampler2D _MainTex;
        //     float4 _MainTex_ST;

        //     v2f vert (appdata v)
        //     {
        //         v2f o;
        //         o.vertex = UnityObjectToClipPos(v.vertex);
        //         o.uv = TRANSFORM_TEX(v.uv, _MainTex);
        //         UNITY_TRANSFER_FOG(o,o.vertex);
        //         return o;
        //     }

        //     fixed4 frag (v2f i) : SV_Target
        //     {
        //         // sample the texture
        //         fixed4 col = tex2D(_MainTex, i.uv);
        //         // apply fog
        //         UNITY_APPLY_FOG(i.fogCoord, col);
        //         return col;
        //     }
        //     ENDCG
        // }
    }
}
