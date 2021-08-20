
attribute vec3 position;
attribute vec2 texcoord;

varying vec2 yuvTexCoord;

void main() {

    gl_Position = vec4(position, 1.0);
    yuvTexCoord = texcoord;
}

