Shader "Unlit/HutaoFace"
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

        _ShadowTex("Shadow Tex", 2D) = "black" {}
        _HalfFaceOffset ("Half Face Offset", Range(-1,1)) = 0
        _FaceShadowFactor ("Face Shadow Factor", Range(-1,1)) = -0.5
        _FaceShadowOffset ("Face Shadow Offset", Range(-1,1)) = 0.55

        _ForwardVector("Forward Vector", Vector) = (0,0,1,0)
        _RightVector("Right Vector", Vector) = (1,0,0,0)
        _SDF("SDF", 2D) = "black" {}
        
        _RampRow("Ramp Row", Range(1,5)) = 5
        _RampTex("Ramp Tex", 2D) = "white" {}

        _OutlineColor ("Outline Color", Color) = (0,0,0,0)
        _OutlineOffset ("Outline Offset", Float) = 0.000015


        _MainTex ("Texture", 2D) = "white" {}

        _MetalTex("Metal Tex", 2D) = "black" {}
        
        _SpecExpon("Spec Exponent", Range(1,512)) = 50
        _KsNonMetallic ("Ks Non-metallic", Range(0,3)) = 1
        _KsMetallic ("Ks Metallic", Range(0,3)) = 1

        _NormalMap ("Normal Map", 2D) = "bump" {}
        _ILM ("ILM", 2D)  = "black" {}

        // _RampTex ("Ramp Tex", 2D) = "white" {}

        _RampMapRow0("Ramp Map Row 0", Range(1,5)) = 1
        _RampMapRow1("Ramp Map Row 1", Range(1,5)) = 4
        _RampMapRow2("Ramp Map Row 2", Range(1,5)) = 3
        _RampMapRow3("Ramp Map Row 3", Range(1,5)) = 5
        _RampMapRow4("Ramp Map Row 4", Range(1,5)) = 2

        _OutlineOffset("Outline Offset", Float) = 1

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

            float _RampRow;

            float3 _ForwardVector;
            float3 _RightVector;
            sampler2D _SDF;
            sampler2D _ShadowTex;
            float _HalfFaceOffset;
            float _FaceShadowFactor;
            float _FaceShadowOffset;

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
                
                Light light = GetMainLight(i.shadowCoord);
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
                float3 N = normalize(i.normalWS);
                float3 V = normalize(mul((float3x3)UNITY_MATRIX_I_V, i.positionVS * (-1)));
                float3 L = normalize(light.direction);
                float3 H = normalize(L+V);

                float NoL = dot(N,L);
                float NoH = dot(N,H);
                float NoV = dot(N,V);

                float3 normalVS = normalize(mul((float3x3)UNITY_MATRIX_V, N));
                float2 matcapUV = normalVS.xy*0.5+0.5;

                float4 baseTex = tex2D(_BaseTex, i.uv);
                float4 toonTex = tex2D(_ToonTex, matcapUV);
                float4 sphereTex = tex2D(_SphereTex, matcapUV);

                float3 baseColor = _AmbientColor.rgb;
                baseColor = saturate(lerp(baseColor, baseColor+ _DiffuseColor.rgb,0.6));
                baseColor = lerp(baseColor,baseColor*baseTex.rgb, _BaseTexFac);
                baseColor = lerp(baseColor,baseColor*toonTex.rgb, _ToonTexFac);
                baseColor = lerp(lerp(baseColor,baseColor*sphereTex.rgb,_SphereTexFac), lerp(baseColor, baseColor+sphereTex.rgb, _SphereTexFac), _SphereMulAdd);

                float rampV = _RampRow/10 - 0.05;
                float rampClampMin = 0.003;
                float2 rampDayUV = float2(rampClampMin, 1-rampV);
                float2 rampNightUV = float2(rampClampMin, 1-(rampV + 0.5));

                float isDay = (L.y + 1)/2;
                float3 rampColor = lerp( tex2D(_RampTex, rampNightUV).rgb, tex2D(_RampTex, rampDayUV).rgb, isDay );

                float3 forwardVec = _ForwardVector;
                float3 rightVec = _RightVector;

                float3 upVector = cross(forwardVec, rightVec);
                // float3 LpU = length(L) * (dot(L, upVector)/(length(L) * length(upVector))) * (upVector/ length(upVector))
                float3 LpU = dot(L, upVector)/pow(length(upVector), 2) * upVector;
                float3 LpHeadHorizon = L - LpU;


                float pi = 3.1415926535;
                float value = acos(dot(normalize(LpHeadHorizon), normalize(rightVec)))/pi;
                float FDotL = dot(normalize(forwardVec), normalize(LpHeadHorizon));
                float FCrossL = cross(normalize(forwardVec), normalize(LpHeadHorizon)).y;
                float2 shadowUV = i.uv;
                shadowUV.x = lerp(shadowUV.x, 1.0 - shadowUV.x, step(0.0, FCrossL));
                // 0-0.5 expose right; 0.5-1 expose left
                float exposeRight = step(value,0.5);               
                // float constrainMix = lerp(-mixValue , mixValue, step(0, dot(normalize(LpHeadHorizon), normalize(forwardVec))));
                

                float sdfRembrandLeft = tex2D(_SDF, float2(1-i.uv.x, i.uv.y)).r;
                float sdfRembrandRight = tex2D(_SDF, i.uv).r;

                float sdf = tex2D(_SDF, shadowUV).r;
                float faceShadow = step(_FaceShadowFactor * FDotL +  _FaceShadowOffset, sdf - _HalfFaceOffset);
                
                float4 shadowTex = tex2D(_ShadowTex, i.uv);
                faceShadow *= shadowTex.g;
                
                faceShadow = lerp(faceShadow, 1 , shadowTex.a);

                float3 shadowColor = baseColor * rampColor * _ShadowColor.rgb; 

                float3 diffuse = lerp(shadowColor, baseColor, faceShadow);

                float3 albedo = diffuse;

                float alpha = _Alpha * baseTex.a * toonTex.a * sphereTex.a;
                alpha = saturate(min(max(IsFacing, _DoubleSided), alpha));
                
                float4 col = float4(albedo, alpha);
                // col.a = col.a-0.5;
                clip(col.a);
 
                col.rgb =  MixFog(col.rgb, i.fogCoord);

                return col;
                // return float4(albedo,1);

            }

            ENDHLSL
        }

        Pass{
            Name "DrawOutline"
            Tags {
                "RenderPipeline" = "UniversalPipeline"
                "RenderType" = "Opaque"
            }
            Cull Front
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata{
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 color : COLOR0;
            };

            struct v2f{
                float2 uv: TEXCOORD0;
                

            };

            CBUFFER_START(UnityPerMaterial)
            sampler2D _BaseTex;
            float4 _BaseTex_ST;

            sampler2D _ILM;

            float4 _OutlineMapColor0;
            float4 _OutlineMapColor1;
            float4 _OutlineMapColor2;
            float4 _OutlineMapColor3;
            float4 _OutlineMapColor4;
            
            float _OutlineOffset;
            CBUFFER_END

            v2f vert(appdata v){
                v2f o;
                return o;
            }

            float4 frag(v2f i, bool IsFacing : sv_IsFrontFace) : SV_Target{

                return float4(1,1,1,1);
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
