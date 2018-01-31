//
//  ViewController.m
//  OpenGL ES iOS
//
//  Created by Mac OS X on 2018/1/31.
//  Copyright © 2018年 Mac OS X. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    
    // 声明GLuint类型变量，用于存放本例中顶点数据的缓存标识符
    GLuint vertexBufferID;
}

@property (nonatomic, strong) GLKBaseEffect *baseEffect;

@property (strong, nonatomic) GLKTextureInfo *textureInfo0;
@property (strong, nonatomic) GLKTextureInfo *textureInfo1;

@end

typedef struct {
    GLKVector3  positionCoords;
    GLKVector2  textureCoords;
}
SceneVertex;

static const SceneVertex vertices[] =
{          // 位置坐标        // 纹理坐标
    {{-1.0f, -0.6f, 0.0f}, {0.0f, 0.0f}},  // 第一个三角形
    {{ 1.0f, -0.6f, 0.0f}, {1.0f, 0.0f}},
    {{-1.0f,  0.6f, 0.0f}, {0.0f, 1.0f}},
    {{ 1.0f, -0.6f, 0.0f}, {1.0f, 0.0f}},  // 第二个三角形
    {{-1.0f,  0.6f, 0.0f}, {0.0f, 1.0f}},
    {{ 1.0f,  0.6f, 0.0f}, {1.0f, 1.0f}},
};


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 将当前view强制转换为GLKView
    GLKView *view = (GLKView *)self.view;
    
    // 断言,检测用storyboard加载的视图是否是GLKView
    NSAssert([view isKindOfClass:[GLKView class]], @"View controller's View is not a GLKView");
    
    // 初始化context为OpenGL ES 2.0
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    // 在任何其他的OpenGL ES配置或者渲染发生前，应用的GLKView实例的上下文属性都需要设置为当前
    [EAGLContext setCurrentContext:view.context];
    
    /*
     初始化baseEffect
     GLKBaseEffect 是GLKit提供的另一个内建类。GLKBaseEffect的存在是为了简化OpenGL ES的很多常用操作。GLKBaseEffect隐藏了iOS设备支持的多个OpenGL ES版本之间的差异。
     
     在OpenGL ES 2.0中，如果没有GLKit和GLKBaseEffect类，完成这个简单的例子需要用着色器语言编写一个GPU程序。
     GLKBaseEffect会在需要的时候自动地构建GPU程序并极大地简化本书中的例子
     */
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    
    self.baseEffect.constantColor = GLKVector4Make(1.0,  // red
                                                   1.0,  // green
                                                   1.0,  // blue
                                                   1.0); // alpha
    
    glClearColor(0.0, 0.0, 0.0, 1.0);
    
    glGenBuffers(1, &vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    NSString *leavesImagePath = [[NSBundle mainBundle] pathForResource:@"leaves" ofType:@"jpg"];
    CGImageRef leavesImageRef = [UIImage imageWithContentsOfFile:leavesImagePath].CGImage;
    self.textureInfo0 = [GLKTextureLoader textureWithCGImage:leavesImageRef options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft, nil] error:NULL];
    
    NSString *beetleImagePath = [[NSBundle mainBundle] pathForResource:@"beetle" ofType:@"jpg"];
    CGImageRef beetleImageRef = [UIImage imageWithContentsOfFile:beetleImagePath].CGImage;
    self.textureInfo1 = [GLKTextureLoader textureWithCGImage:beetleImageRef options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft, nil] error:NULL];
 
    // 开启混合
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

- (void)update{
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    // 前两行为渲染前的“清除”操作，清除颜色缓冲区和深度缓冲区中的内容。
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 启动顶点缓存渲染操作
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    /*
     告诉OpenGL ES每个顶点数据如何使用。
     第一个参数：指示当前绑定的缓存包含每个顶点的位置信息，也就是给哪个顶点属性赋值
     第二个参数：指定每个位置又3个数据部分
     第三个参数：告诉OpenGL ES每个部分都保存为一个浮点类型的值
     第四个参数：告诉OpenGL ES小数点固定数据是否可以被改变，本例中没有使用小数点固定的数据，因此赋值为GL_FALSE
     第五个参数：可以称为"步幅"，指定了没哥顶点的保存需要多少个字节。简单点就是指定了GPU从一个顶点的内存碍事转到下一个顶点的内存开始位置需要跳过多少字节
     第六个参数：告诉OpenGL ES可以从当前绑定的顶点缓存的开始位置访问顶点数据
     */
    GLsizei positionOffset = offsetof(SceneVertex, positionCoords);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL + positionOffset);
    
    GLsizei textureOffset = offsetof(SceneVertex, textureCoords);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL + textureOffset);
    
    self.baseEffect.texture2d0.name = self.textureInfo0.name;
    self.baseEffect.texture2d0.target = self.textureInfo0.target;
    [self.baseEffect prepareToDraw];
    
    /*
     告诉OpenGL ES如何使用缓存数据之后就可以调用glDrawArrays()函数通过这些数据来绘制图形了
     第一个参数：告诉OpenGL ES怎么处理在绑定的顶点缓存内的顶点数据。本例中屎指示OpenGL ES去渲染三角形
     第二个参数：指定缓存内的需要渲染的第一个顶点的位置
     第三个参数：需要渲染的顶点数量
     */
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    self.baseEffect.texture2d0.name = self.textureInfo1.name;
    self.baseEffect.texture2d0.target = self.textureInfo1.target;
    [self.baseEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
