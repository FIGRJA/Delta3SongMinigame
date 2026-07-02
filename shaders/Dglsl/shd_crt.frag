//#version 120
//#define LOWPREC 
//#define lowp
//#define mediump
//#define highp
//#define precision
// Uniforms look like they're shared between vertex and fragment shaders in GLSL, so we have to be careful to avoid name clashes

//openfl standart

varying float openfl_Alphav;
varying vec4 openfl_ColorMultiplierv;
varying vec4 openfl_ColorOffsetv;
varying vec2 openfl_TextureCoordv;

uniform bool openfl_HasColorTransform;
uniform vec2 openfl_TextureSize;
uniform sampler2D bitmap;

uniform bool hasTransform;
uniform bool hasColorTransform;

//
//uniform sampler2D gm_BaseTexture ;//bitmap

uniform bool gm_PS_FogEnabled;
uniform vec4 gm_FogColour;
//uniform bool gm_AlphaTestEnabled;
//uniform float gm_AlphaRefValue;

void DoAlphaTest(vec4 SrcColour)
{
	if (hasColorTransform)
	{
		if (SrcColour.a <= openfl_Alphav)
		{
			discard;
		}
	}
}

void DoFog(inout vec4 SrcColour, float fogval)
{
	if (gm_PS_FogEnabled)
	{
		SrcColour = mix(SrcColour, gm_FogColour, clamp(fogval, 0.0, 1.0)); 
	}
}

#define _YY_GLSL_ 1
//varying vec2 v_vTexcoord;//openfl_TextureCoordv
//varying vec4 v_vColour ;//openfl_ColorOffsetv

uniform vec2 texel;
uniform float vignette_scale;
uniform float vignette_intensity;
uniform float chromatic_scale;
uniform float filter_amount;
uniform float time;

void main()
{	
	vec4 col = texture2D( bitmap, openfl_TextureCoordv);
	
	//RGB filter
	float rgbindex = floor(mod(gl_FragCoord.x+gl_FragCoord.y-time,3.));
	vec3 rgbcol = vec3(max(0.,1.-rgbindex),mod(rgbindex,2.0)*0.5,max(0.,rgbindex-1.));
	//col.rgb = mix(col.rgb,rgbcol,filter_amount);
	col.rgb = col.rgb*rgbcol*filter_amount;
	//Chromatic aberration 
	float dist = length(openfl_TextureCoordv - vec2(0.5,0.5));
	dist *= chromatic_scale;
	float signdist = sign(chromatic_scale);
    float shift = texel.x*(signdist+dist);
    col.r = texture2D(bitmap, vec2(openfl_TextureCoordv.x + shift, openfl_TextureCoordv.y)).r;
    col.b = texture2D(bitmap, vec2(openfl_TextureCoordv.x - shift, openfl_TextureCoordv.y)).b;
	//gl_FragColor = col;

	//Vignette
	vec2 vuv = openfl_TextureCoordv * (1.0 - openfl_TextureCoordv.yx);    
    float vig = vuv.x*vuv.y * vignette_intensity;
    float bri = pow(vig, vignette_scale);
	col.rgb *= bri;
    gl_FragColor = col ;//* openfl_ColorOffsetv;
		
}
