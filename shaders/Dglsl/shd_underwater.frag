//#version 120
#define LOWPREC 
#define lowp
#define mediump
#define highp
#define precision
// Uniforms look like they're shared between vertex and fragment shaders in GLSL, so we have to be careful to avoid name clashes

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
const int Quality = 5;
const int Directions = 2;
const float Pi2 = 6.28318530718;//pi * 2
const float WaveWidth = 16.0;
uniform float baseAngle;
uniform float Radius;
uniform float time;

void main()
{
	//Water wave
	vec3 size = vec3(320.0,240.0,Radius); //Update as per size of application surface!!
	vec2 coord = openfl_TextureCoordv;
	coord.y = coord.y + ((Radius/3.0)/size.y) * sin(time + (coord.x/(WaveWidth/size.x)));
	
	//Blur effect
	vec2 radius = size.z/size.xy;
    vec4 Color = texture2D( bitmap, coord);
	float loops = 0.0;
    for( float d=0.0; d<Pi2; d+=Pi2/float(Directions) )
    {
        for( float i=1.0/float(Quality);i<=1.0;i+=1.0/float(Quality) )
        {
                Color += texture2D( bitmap, coord+vec2(cos(d+baseAngle),sin(d+baseAngle))*radius*i);
				loops += 1.0;
        }
    }
    Color /= loops+1.0;//ceil(float(Quality)*float(Directions));
    gl_FragColor =  Color ;//*  openfl_ColorOffsetv;
}
