// vim: set ft=glsl:

// roughly corresponds to fk3db parameters, which this algorithm is
// loosely inspired by
#define threshold 64
#define range     32
#define grain     16

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec4 sample(sampler2D tex, vec2 pos, vec2 size, vec2 sub, float cmax)
{
    // Compute a random angle and distance
    float dist = rand(pos) * range;
    vec2 pt = dist / (size * sub);
    float dir = rand(pos.yx) * 6.2831853;
    vec2 o = vec2(cos(dir), sin(dir));

    // Sample at quarter-turn intervals around the source pixel
    vec4 ref[4];
    ref[0] = texture(tex, pos + pt * vec2( o.x,  o.y));
    ref[1] = texture(tex, pos + pt * vec2(-o.y,  o.x));
    ref[2] = texture(tex, pos + pt * vec2(-o.x, -o.y));
    ref[3] = texture(tex, pos + pt * vec2( o.y, -o.x));

    // Average and compare with the actual sample
    vec4 avg = (ref[0] + ref[1] + ref[2] + ref[3])/4.0;
    vec4 col = texture(tex, pos);
    vec4 diff = abs(col - avg);

    // Use the average if below the threshold
    col = mix(avg, col, greaterThan(diff, vec4(threshold*cmax/16384.0)));

    // Add some random noise to the output
    col.rgb += (grain*cmax/8192.0) * (vec3(rand(2*pos) - vec3(0.5)));
    return col;
}