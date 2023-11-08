// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Water"
{
	Properties
	{
		_FlowTexture("Flow Texture", 2D) = "white" {}
		_Size("Size", Float) = 2
		_FlowStrength("Flow Strength", Float) = 0.008
		_FlowSpeed("Flow Speed", Float) = 0.1
		_WaterColor("Water Color", Color) = (0.04313726,0.8156863,0.8666667,1)
		_FoamTexture("Foam Texture", 2D) = "white" {}
		_LightFoamColor("Light Foam Color", Color) = (0.6078432,1,1,1)
		_DarkFoamColor("Dark Foam Color", Color) = (0.01176471,0.2745098,0.2901961,1)
		_EdgeFoamColor("Edge Foam Color", Color) = (0.6078432,1,1,1)
		_FoamDistance("Foam Distance", Float) = 1.5
		_RippleFoamThickness("Ripple Foam Thickness", Float) = 0.6
		_RippleStrength("Ripple Strength", Float) = 1

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Transparent" }
	LOD 100

		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend Off
		AlphaToMask Off
		Cull Back
		ColorMask RGBA
		ZWrite On
		ZTest LEqual
		Offset 0 , 0
		
		
		
		Pass
		{
			Name "Unlit"
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(UNITY_COMPILER_HLSLCC) || defined(SHADER_API_PSSL) || (defined(SHADER_TARGET_SURFACE_ANALYSIS) && !defined(SHADER_TARGET_SURFACE_ANALYSIS_MOJOSHADER))//ASE Sampler Macros
			#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex.Sample(samplerTex,coord)
			#else//ASE Sampling Macros
			#define SAMPLE_TEXTURE2D(tex,samplerTex,coord) tex2D(tex,coord)
			#endif//ASE Sampling Macros
			


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform half _RippleFoamThickness;
			UNITY_DECLARE_TEX2D_NOSAMPLER(_RippleRT);
			uniform half3 _CamPosition;
			uniform half _OrthographicCamSize;
			SamplerState sampler_RippleRT;
			uniform half4 _EdgeFoamColor;
			uniform half4 _WaterColor;
			uniform half4 _DarkFoamColor;
			UNITY_DECLARE_TEX2D_NOSAMPLER(_FoamTexture);
			uniform half _RippleStrength;
			UNITY_DECLARE_TEX2D_NOSAMPLER(_FlowTexture);
			uniform half _FlowSpeed;
			uniform half _Size;
			SamplerState sampler_FlowTexture;
			uniform half _FlowStrength;
			SamplerState sampler_FoamTexture;
			uniform half4 _LightFoamColor;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform half _FoamDistance;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				
				o.ase_texcoord1.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.zw = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				half4 tex2DNode97 = SAMPLE_TEXTURE2D( _RippleRT, sampler_RippleRT, ( ( ( WorldPosition.xz - _CamPosition.xz ) / ( _OrthographicCamSize * 2.0 ) ) + float3( 0.5,0.5,0.5 ) ).xy );
				half temp_output_104_0 = ( tex2DNode97.b * tex2DNode97.a );
				half2 texCoord22 = i.ase_texcoord1.xy * float2( 0.5,0.5 ) + float2( 0,0 );
				half2 texCoord15 = i.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				half2 temp_output_2_0_g1 = ( texCoord15 + ( _Time.y * ( _FlowSpeed / _Size ) ) );
				half2 break6_g1 = temp_output_2_0_g1;
				half temp_output_25_0_g1 = ( pow( 1.0 , 3.0 ) * 0.1 );
				half2 appendResult8_g1 = (half2(( break6_g1.x + temp_output_25_0_g1 ) , break6_g1.y));
				half4 tex2DNode14_g1 = SAMPLE_TEXTURE2D( _FlowTexture, sampler_FlowTexture, temp_output_2_0_g1 );
				half temp_output_4_0_g1 = 1.0;
				half3 appendResult13_g1 = (half3(1.0 , 0.0 , ( ( SAMPLE_TEXTURE2D( _FlowTexture, sampler_FlowTexture, appendResult8_g1 ).g - tex2DNode14_g1.g ) * temp_output_4_0_g1 )));
				half2 appendResult9_g1 = (half2(break6_g1.x , ( break6_g1.y + temp_output_25_0_g1 )));
				half3 appendResult16_g1 = (half3(0.0 , 1.0 , ( ( SAMPLE_TEXTURE2D( _FlowTexture, sampler_FlowTexture, appendResult9_g1 ).g - tex2DNode14_g1.g ) * temp_output_4_0_g1 )));
				half3 normalizeResult22_g1 = normalize( cross( appendResult13_g1 , appendResult16_g1 ) );
				half3 temp_output_8_0 = ( ( ( temp_output_104_0 * _RippleStrength ) + normalizeResult22_g1 ) * _FlowStrength );
				half3 temp_output_23_0 = ( ( half3( texCoord22 ,  0.0 ) + temp_output_8_0 ) * _Size );
				half4 lerpResult37 = lerp( _WaterColor , _DarkFoamColor , SAMPLE_TEXTURE2D( _FoamTexture, sampler_FoamTexture, ( float3( 0.1,0.1,0 ) + temp_output_23_0 ).xy ));
				half4 lerpResult41 = lerp( lerpResult37 , _LightFoamColor , SAMPLE_TEXTURE2D( _FoamTexture, sampler_FoamTexture, temp_output_23_0.xy ));
				float4 screenPos = i.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				half eyeDepth79 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ( half4( temp_output_8_0 , 0.0 ) + ase_screenPosNorm ).xy ));
				half4 lerpResult54 = lerp( _EdgeFoamColor , lerpResult41 , step( 0.5 , saturate( ( ( eyeDepth79 - screenPos.w ) / _FoamDistance ) ) ));
				
				
				finalColor = ( step( _RippleFoamThickness , temp_output_104_0 ) + lerpResult54 );
				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18400
290;75;686;784;-665.949;2032.14;1;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;92;111.7269,-1471.324;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;90;167.3776,-1025.389;Inherit;False;Global;_OrthographicCamSize;_OrthographicCamSize;10;0;Create;True;0;0;False;0;False;0;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;91;108.0278,-1300.508;Inherit;False;Global;_CamPosition;_CamPosition;10;0;Create;True;0;0;False;0;False;0,0,0;-0.3919042,50,11.18236;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;94;437.1579,-987.5545;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;93;423.8568,-1400.999;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-1601.783,340.6944;Inherit;False;Property;_FlowSpeed;Flow Speed;5;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-1591.638,561.2495;Inherit;False;Property;_Size;Size;3;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;95;731.6125,-1268.849;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleTimeNode;9;-1382.452,107.3948;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;89;1049.156,-1398.804;Inherit;True;Global;_RippleRT;_RippleRT;12;0;Create;True;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleAddOpNode;96;1063.833,-1183.309;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0.5,0.5,0.5;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;13;-1364.667,424.2498;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-1094.873,213.4748;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;97;1375.688,-1202.099;Inherit;True;Property;_TextureSample3;Texture Sample 3;10;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;15;-1100.573,-72.53059;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;14;-732.9112,39.16964;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;105;1708.549,-893.2766;Inherit;False;Property;_RippleStrength;Ripple Strength;14;0;Create;True;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;88;-743.2606,-203.1296;Inherit;True;Property;_FlowTexture;Flow Texture;2;0;Create;True;0;0;False;0;False;b302bc815c2df468ca225bf32164469a;b302bc815c2df468ca225bf32164469a;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;1720.298,-1191.917;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;87;-448.6406,-19.82957;Inherit;True;NormalCreate;0;;1;e12f7ae19d416b942820e3932b56220f;0;4;1;SAMPLER2D;;False;2;FLOAT2;0,0;False;3;FLOAT;1;False;4;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;102;1960.389,-1007.469;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-426.6668,295.2598;Inherit;False;Property;_FlowStrength;Flow Strength;4;0;Create;True;0;0;False;0;False;0.008;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;27;-1376.551,663.7786;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;103;2233.583,-844.0989;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-63.58707,113.0148;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;22;-67.95357,-176.5287;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;0.5,0.5;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;29;-334.6474,573.1336;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;45;-77.71249,894.861;Float;True;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;21;269.3401,-10.21838;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;44;200.8673,678.0108;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;28;442.3275,253.4831;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;86;448.7916,886.2894;Float;True;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;535.0316,-10.37348;Inherit;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScreenDepthNode;79;477.4632,650.8496;Inherit;False;0;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;840.8009,-286.5321;Inherit;True;2;2;0;FLOAT3;0.1,0.1,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;33;547.2029,210.9687;Inherit;True;Property;_FoamTexture;Foam Texture;7;0;Create;True;0;0;False;0;False;d3834560581fa478880dc11f68467b01;d3834560581fa478880dc11f68467b01;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;43;787.4775,950.3112;Inherit;False;Property;_FoamDistance;Foam Distance;11;0;Create;True;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;50;753.687,692.4209;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;40;1130.884,-867.9631;Inherit;False;Property;_WaterColor;Water Color;6;0;Create;True;0;0;False;0;False;0.04313726,0.8156863,0.8666667,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;25;890.3955,18.27118;Inherit;True;Property;_TextureSample0;Texture Sample 0;4;0;Create;True;0;0;False;0;False;36;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;39;1132.394,-640.2834;Inherit;False;Property;_DarkFoamColor;Dark Foam Color;9;0;Create;True;0;0;False;0;False;0.01176471,0.2745098,0.2901961,1;0.01176471,0.2745098,0.2901961,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;36;1072.44,-415.5117;Inherit;True;Property;_TextureSample1;Texture Sample 1;4;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;25;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;51;1123.107,726.481;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;38;1427.629,-274.8532;Inherit;False;Property;_LightFoamColor;Light Foam Color;8;0;Create;True;0;0;False;0;False;0.6078432,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;37;1428.08,-549.5567;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;42;1581.783,-70.1087;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;52;1352.636,733.031;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;41;1723.768,-294.119;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;106;1708.548,-34.6921;Inherit;False;Property;_EdgeFoamColor;Edge Foam Color;10;0;Create;True;0;0;False;0;False;0.6078432,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;101;1464.472,-1480.085;Inherit;False;Property;_RippleFoamThickness;Ripple Foam Thickness;13;0;Create;True;0;0;False;0;False;0.6;0.75;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;53;1566.861,677.4164;Inherit;True;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;54;2089.686,-33.21349;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;100;2152.622,-1359.716;Inherit;True;2;0;FLOAT;0.99;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;99;2749.96,-604.0336;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;61;3050.621,-601.8199;Half;False;True;-1;2;ASEMaterialInspector;100;1;Water;0770190933193b94aaa3065e307002fa;True;Unlit;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Transparent=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;1;True;False;;True;0
WireConnection;94;0;90;0
WireConnection;93;0;92;0
WireConnection;93;1;91;0
WireConnection;95;0;93;0
WireConnection;95;1;94;0
WireConnection;96;0;95;0
WireConnection;13;0;4;0
WireConnection;13;1;2;0
WireConnection;12;0;9;0
WireConnection;12;1;13;0
WireConnection;97;0;89;0
WireConnection;97;1;96;0
WireConnection;14;0;15;0
WireConnection;14;1;12;0
WireConnection;104;0;97;3
WireConnection;104;1;97;4
WireConnection;87;1;88;0
WireConnection;87;2;14;0
WireConnection;102;0;104;0
WireConnection;102;1;105;0
WireConnection;27;0;2;0
WireConnection;103;0;102;0
WireConnection;103;1;87;0
WireConnection;8;0;103;0
WireConnection;8;1;3;0
WireConnection;29;0;27;0
WireConnection;21;0;22;0
WireConnection;21;1;8;0
WireConnection;44;0;8;0
WireConnection;44;1;45;0
WireConnection;28;0;29;0
WireConnection;23;0;21;0
WireConnection;23;1;28;0
WireConnection;79;0;44;0
WireConnection;34;1;23;0
WireConnection;50;0;79;0
WireConnection;50;1;86;4
WireConnection;25;0;33;0
WireConnection;25;1;23;0
WireConnection;36;1;34;0
WireConnection;51;0;50;0
WireConnection;51;1;43;0
WireConnection;37;0;40;0
WireConnection;37;1;39;0
WireConnection;37;2;36;0
WireConnection;42;0;25;0
WireConnection;52;0;51;0
WireConnection;41;0;37;0
WireConnection;41;1;38;0
WireConnection;41;2;42;0
WireConnection;53;1;52;0
WireConnection;54;0;106;0
WireConnection;54;1;41;0
WireConnection;54;2;53;0
WireConnection;100;0;101;0
WireConnection;100;1;104;0
WireConnection;99;0;100;0
WireConnection;99;1;54;0
WireConnection;61;0;99;0
ASEEND*/
//CHKSM=426C71FE502AEA37F3F214D5B883DC6DA19D2D18