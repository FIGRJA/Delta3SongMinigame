#pragma header

void main() {
    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
    vec3 targetGray = vec3(0.047, 0.086, 0.47);
    float threshold = 0.01
    ;
    
    if (abs(color.r - targetGray.r) < threshold &&
        abs(color.g - targetGray.g) < threshold &&
        abs(color.b - targetGray.b) < threshold) {
        gl_FragColor = vec4(0.0, 0.0, 1.0, 0.01);
    } else {
        gl_FragColor = color;
    }
}