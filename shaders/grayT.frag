#pragma header

uniform vec3 colorMain = vec3(0, 0, 0);
void main() 
{
    vec4 color = texture2D(bitmap, openfl_TextureCoordv );
    float gray = dot(color.rgb, colorMain.rgb );
    gl_FragColor = vec4(0,1,0, 0.5);
}