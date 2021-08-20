precision highp float;
varying highp vec2 yuvTexCoord;
uniform sampler2D s_texture_y;
uniform sampler2D s_texture_u;
uniform sampler2D s_texture_v;

void main() {
highp float y = texture2D(s_texture_y,yuvTexCoord).r;
highp float u = texture2D(s_texture_u,yuvTexCoord).r - 0.5;
highp float v = texture2D(s_texture_v,yuvTexCoord).r - 0.5;

highp float r = y + 1.402 * v;
highp float g = y - 0.344 * u - 0.714 * v;
highp float b = y + 1.772 * u;
gl_FragColor=vec4(r,g,b,1.0);
}
