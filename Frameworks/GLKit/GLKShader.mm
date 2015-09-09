//******************************************************************************
//
// Copyright (c) 2015 Microsoft Corporation. All rights reserved.
//
// This code is licensed under the MIT License (MIT).
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
//******************************************************************************

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#import <Starboard.h>
#import <GLKit/GLKitExport.h>
#import <GLKit/GLKEffect.h>
#import <GLKit/GLKShader.h>
#import <GLKit/GLKShaderDefs.h>

#import "ShaderInfo.h"

@implementation GLKShaderPair
@end

@implementation GLKShaderCache {
    NSMutableDictionary* _shaders;
}

static GLKShaderCache* imp = nil;

+(instancetype) get {
    if (imp == nil) {
        imp = [[GLKShaderCache alloc] init];
    }
    return imp;
}

-(GLKShader*)addShaderNamed: (NSString*)name source: (GLKShaderPair*)src
{
    GLKShader* s = [_shaders objectForKey: name];
    if (s) return s;

    GLuint vsh = glCreateShader(GL_VERTEX_SHADER);
    GLuint psh = glCreateShader(GL_FRAGMENT_SHADER);

    GLint compileStatus = 0;

    const char* vsrces[] = { [src.vertexShader UTF8String] };
    const int vlens[] = { src.vertexShader.length };
    glShaderSource(vsh, 1, vsrces, vlens);
    glCompileShader(vsh);
    glGetShaderiv(vsh, GL_COMPILE_STATUS, &compileStatus);
    if (compileStatus == GL_FALSE) {
        NSLog(@"WARNING: vertex shader compilation failed!");
        return nil;
    }

    const char* psrces[] = { [src.pixelShader UTF8String] };
    const int plens[] = { src.pixelShader.length };
    glShaderSource(psh, 1, psrces, plens);
    glCompileShader(psh);
    glGetShaderiv(psh, GL_COMPILE_STATUS, &compileStatus);
    if (compileStatus == GL_FALSE) {
        NSLog(@"WARNING: pixel shader compilation failed!");
        return nil;
    }

    GLuint program = glCreateProgram();
    glAttachShader(program, vsh);
    glAttachShader(program, psh);

    // Enforce common vertex format standard via attribute naming.
    glBindAttribLocation(program, GLKVertexAttribPosition,  GLKSH_POS_NAME);
    glBindAttribLocation(program, GLKVertexAttribNormal,    GLKSH_NORMAL_NAME);
    glBindAttribLocation(program, GLKVertexAttribColor,     GLKSH_COLOR_NAME);
    glBindAttribLocation(program, GLKVertexAttribTexCoord0, GLKSH_UV0_NAME);
    glBindAttribLocation(program, GLKVertexAttribTexCoord1, GLKSH_UV1_NAME);

    glLinkProgram(program);

    // Final object.
    s = [[GLKShader alloc] initWith: program];
    [_shaders setObject: s forKey: name];
    return s;
}

-(GLKShader*)shaderNamed: (NSString*)name {
    return [_shaders objectForKey: name];
}

-(id)init {
    _shaders = [[NSMutableDictionary alloc] init];
    return self;
}

@end

@implementation GLKShader {
    ShaderLayout vars;
}

-(id)initWith: (GLuint)prog {
    [self init];
    _program = prog;

    GLint numAttrs = 0, numUniforms = 0;
    glGetProgramiv(prog, GL_ACTIVE_ATTRIBUTES, &numAttrs);
    glGetProgramiv(prog, GL_ACTIVE_UNIFORMS, &numUniforms);

    GLsizei len = 0;
    char buf[1024];
    GLint size;
    GLenum type;

    // Build shader layout.
    
    for(int i = 0; i < numAttrs; i ++) {
        glGetActiveAttrib(prog, i, sizeof(buf), &len, &size, &type, buf);
        GLint loc = glGetAttribLocation(prog, buf);
        vars.add(buf, loc, size, true);
    }

    for(int i = 0; i < numUniforms; i ++) {
        glGetActiveUniform(prog, i, sizeof(buf), &len, &size, &type, buf);
        GLint loc = glGetUniformLocation(prog, buf);
        if (strcmp(buf, GLKSH_MVP_NAME) == 0) {
            _mvploc = loc;
        } else {
            vars.add(buf, loc, size, false, type == GL_SAMPLER_2D); // TODO: BK: more types go here.
        }
    }
    
    return self;
}

-(GLKShaderLayoutPtr)layout {
    return &vars;
}
  
@end

