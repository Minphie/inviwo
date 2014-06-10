/*********************************************************************************
 *
 * Inviwo - Interactive Visualization Workshop
 * Version 0.6b
 *
 * Copyright (c) 2012-2014 Inviwo Foundation
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Main file authors: Timo Ropinski, Erik Sund�n
 *
 *********************************************************************************/

#include "include/inc_sampler2d.frag"
#include "include/inc_sampler3d.frag"
#include "include/inc_raycasting.frag"
#include "include/inc_classification.frag"
#include "include/inc_gradients.frag"
#include "include/inc_shading.frag"
#include "include/inc_compositing.frag"
#include "include/inc_depth.frag"

uniform TEXTURE_TYPE entryColorTex_;
uniform TEXTURE_TYPE entryDepthTex_;
uniform TEXTURE_PARAMETERS entryParameters_;
uniform TEXTURE_TYPE exitColorTex_;
uniform TEXTURE_TYPE exitDepthTex_;
uniform TEXTURE_PARAMETERS exitParameters_;

uniform VOLUME_TYPE volume_;
uniform VOLUME_PARAMETERS volumeParameters_;

uniform int channel_;

// set threshold for early ray termination
#define ERT_THRESHOLD 0.95

vec4 rayTraversal(vec3 entryPoint, vec3 exitPoint, vec2 texCoords) {
    vec4 result = vec4(0.0);
    vec3 rayDirection = exitPoint - entryPoint;
    float tEnd = length(rayDirection);
    float tIncr = min(tEnd, tEnd / (samplingRate_*length(rayDirection*volumeParameters_.dimensions_)));
    float samples = ceil(tEnd/tIncr);
    tIncr = tEnd/samples;
    float t = 0.5f*tIncr; 
    rayDirection = normalize(rayDirection);
    float tDepth = -1.0;
    vec4 color; vec4 voxel;
    vec3 samplePos; vec3 gradient;
    while (t < tEnd) {
        samplePos = entryPoint + t * rayDirection;
        voxel = getVoxel(volume_, volumeParameters_, samplePos);
        gradient = RC_CALC_GRADIENTS_FOR_CHANNEL(voxel, samplePos, volume_, volumeParameters_, t, rayDirection, entryTex_, entryParameters_, channel_);
        color = RC_APPLY_CLASSIFICATION_FOR_CHANNEL(transferFunc_, voxel, channel_);
        color.rgb = RC_APPLY_SHADING(color.rgb, color.rgb, vec3(1.0), samplePos, gradient, lightPosition_, vec3(0.0));
        result = RC_APPLY_COMPOSITING(result, color, samplePos, voxel, gradient, t, tDepth, tIncr);

        // early ray termination
        if (result.a > ERT_THRESHOLD) t = tEnd;
        else t += tIncr;
    }

    if (tDepth != -1.0)
        tDepth = calculateDepthValue(tDepth, texture(entryDepthTex_, texCoords).z, texture(exitDepthTex_, texCoords).z);
    else
        tDepth = 1.0;

    gl_FragDepth = tDepth;
    return result;
}

void main() {
    vec2 texCoords = gl_FragCoord.xy * screenDimRCP_;
    vec3 entryPoint = texture(entryColorTex_, texCoords).rgb;
    vec3 exitPoint = texture(exitColorTex_, texCoords).rgb;

    if (entryPoint == exitPoint) discard;

    vec4 color = rayTraversal(entryPoint, exitPoint, texCoords);
    FragData0 = color;
}