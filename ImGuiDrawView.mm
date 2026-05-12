//Require standard library
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#include <iostream>
#include <UIKit/UIKit.h>
#include <vector>
#import "pthread.h"
#include <array>
#import <os/log.h>
#include <cmath>
#include <deque>
#include <fstream>
#include <algorithm>
#include <string>
#include <sstream>
#include <cstring>
#include <cstdlib>
#include <cstdio>
#include <cstdint>
#include <cinttypes>
#include <cerrno>
#include <cctype>
//Imgui library
#import "Esp/CaptainHook.h"
#import "Esp/ImGuiDrawView.h"
#import "IMGUI/imgui.h"
#import "IMGUI/imgui_internal.h"
#import "IMGUI/imgui_impl_metal.h"
#import "IMGUI/zzz.h"
#import "Hosts/NSObject+URL.h"
#include "oxorany/oxorany_include.h"
#import "Helper/Mem.h"
#include "font.h"
#import "Helper/Vector3.h"
#import "Helper/Vector2.h"
#import "Helper/Quaternion.h"
#import "Helper/Monostring.h"
#include "Helper/font.h"
#include "Helper/data.h"
ImFont* verdana_smol;
ImFont* pixel_big = {};
ImFont* pixel_smol = {};
#include "Helper/Obfuscate.h"
#import "Helper/Hooks.h"

game_sdk_t *game_sdk = new game_sdk_t();

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <unistd.h>
#include <string.h>
#include "Zexishook/hook.h"
#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define kScale [UIScreen mainScreen].scale

@interface ImGuiDrawView () <MTKViewDelegate>
@property (nonatomic, strong) id <MTLDevice> device;
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;
@end

@implementation ImGuiDrawView
ImFont *_espFont;
ImFont* verdanab;
ImFont* icons;
ImFont* interb;
ImFont* Urbanist;
static bool MenDeal = true;
static int DuckTabIndex = 0;
static const char* DuckTabNames[] = {"ESP", "AIMBOT", "INFO"};
static const ImVec4 DuckAccentColor = ImVec4(0.43f, 0.55f, 0.98f, 1.0f);


- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];

    if (!self.device) abort();

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;

   ImGui::StyleColorsClassic();
    auto& Style = ImGui::GetStyle();
    Style.WindowPadding = ImVec2(16.0f, 16.0f);
    Style.FramePadding = ImVec2(12.0f, 10.0f);
    Style.ItemSpacing = ImVec2(10.0f, 10.0f);
    Style.ItemInnerSpacing = ImVec2(10.0f, 8.0f);
    Style.GrabRounding = 10.0f;
    Style.FrameRounding = 14.0f;
    Style.ScrollbarRounding = 10.0f;
    Style.TabRounding = 12.0f;
    Style.WindowRounding = 18.0f;
            ImVec4* colors = ImGui::GetStyle().Colors;
        colors[ImGuiCol_WindowBg] = ImVec4(0.04f, 0.05f, 0.08f, 0.98f);
        colors[ImGuiCol_PopupBg] = ImVec4(0.09f, 0.09f, 0.09f, 1.00f);
        colors[ImGuiCol_FrameBg] = ImVec4(0.19f, 0.19f, 0.19f, 0.54f);
        colors[ImGuiCol_FrameBgHovered] = ImVec4(0.17f, 0.17f, 0.17f, 0.40f);
        colors[ImGuiCol_FrameBgActive] = ImVec4(0.31f, 0.31f, 0.31f, 1.00f);
        colors[ImGuiCol_TitleBg] = ImVec4(0.06f, 0.06f, 0.06f, 1.00f);
        colors[ImGuiCol_TitleBgActive] = ImVec4(0.14f, 0.14f, 0.14f, 1.00f);
        colors[ImGuiCol_CheckMark] = ImColor(163, 122, 195).Value;
        colors[ImGuiCol_ScrollbarBg] = ImVec4(0, 0, 0, 0);
        colors[ImGuiCol_ScrollbarGrab] = ImColor(163, 122, 195).Value;
        colors[ImGuiCol_ScrollbarGrabHovered] = ImColor(163, 122, 195).Value;
        colors[ImGuiCol_ScrollbarGrabActive] = ImColor(163, 122, 195).Value;
        colors[ImGuiCol_SliderGrab] = ImColor(163, 122, 195).Value;
        colors[ImGuiCol_SliderGrabActive] = ImColor(163, 122, 195).Value;
        colors[ImGuiCol_Button] = ImVec4(0.24f, 0.24f, 0.24f, 0.40f);
        colors[ImGuiCol_ButtonHovered] = ImVec4(0.25f, 0.25f, 0.25f, 1.00f);
        colors[ImGuiCol_ButtonActive] = ImVec4(0.32f, 0.32f, 0.32f, 1.00f);
        colors[ImGuiCol_Header] = ImVec4(0.73f, 0.73f, 0.73f, 0.31f);
        colors[ImGuiCol_HeaderHovered] = ImVec4(0.65f, 0.65f, 0.65f, 0.80f);
        colors[ImGuiCol_HeaderActive] = ImVec4(0.72f, 0.72f, 0.72f, 1.00f);
        colors[ImGuiCol_Separator] = ImVec4(0.50f, 0.50f, 0.50f, 0.50f);
        colors[ImGuiCol_SeparatorHovered] = ImVec4(0.52f, 0.52f, 0.52f, 0.78f);
        colors[ImGuiCol_SeparatorActive] = ImVec4(0.49f, 0.49f, 0.49f, 1.00f);
        colors[ImGuiCol_ResizeGrip] = ImColor(163, 122, 195).Value;
        colors[ImGuiCol_ResizeGripHovered] = ImColor(163, 122, 195).Value;
        colors[ImGuiCol_ResizeGripActive] = ImColor(163, 122, 195).Value;
        colors[ImGuiCol_Tab] = ImVec4(0.17f, 0.17f, 0.17f, 0.86f);
        colors[ImGuiCol_TabHovered] = ImVec4(0.29f, 0.29f, 0.29f, 0.80f);
        colors[ImGuiCol_TabActive] = ImVec4(0.40f, 0.40f, 0.40f, 1.00f);
        colors[ImGuiCol_TabUnfocused] = ImVec4(0.11f, 0.11f, 0.11f, 0.97f);
        colors[ImGuiCol_TabUnfocusedActive] = ImVec4(0.17f, 0.17f, 0.17f, 1.00f);
        colors[ImGuiCol_TextSelectedBg] = ImVec4(0.59f, 0.11f, 0.11f, 0.35f);
        colors[ImGuiCol_NavHighlight] = ImVec4(0.28f, 0.28f, 0.28f, 1.00f);
        ImGui::GetStyle().Colors[ImGuiCol_WindowBg] = ImColor(28, 28, 30);
        ImGui::GetStyle().Colors[ImGuiCol_Border] = ImColor(36, 36, 38);
        ImGui::GetStyle().Colors[ImGuiCol_ChildBg] = ImColor(36, 36, 38);

        ImGui::GetStyle().WindowRounding = 8 / 1.5f;
        ImGui::GetStyle().FrameRounding = 4 / 1.5f;
        ImGui::GetStyle().ChildRounding = 6 / 1.5f;
    ImFont* font = io.Fonts->AddFontFromMemoryTTF(sansbold, sizeof(sansbold), 15.0f, NULL, io.Fonts->GetGlyphRangesCyrillic());
    verdana_smol = io.Fonts->AddFontFromMemoryTTF(verdana, sizeof verdana, 40, NULL, io.Fonts->GetGlyphRangesCyrillic());
    pixel_big = io.Fonts->AddFontFromMemoryTTF((void*)smallestpixel, sizeof smallestpixel, 128, NULL, io.Fonts->GetGlyphRangesCyrillic());
    pixel_smol = io.Fonts->AddFontFromMemoryTTF((void*)smallestpixel, sizeof smallestpixel, 10*2, NULL, io.Fonts->GetGlyphRangesCyrillic());
    ImGui_ImplMetal_Init(_device);

    return self;
}

+ (void)showChange:(BOOL)open
{
    MenDeal = open;
}

- (MTKView *)mtkView
{
    return (MTKView *)self.view;
}

- (void)loadView
{

 

    CGFloat w = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.width;
    CGFloat h = [UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.height;
    self.view = [[MTKView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mtkView.device = self.device;
    self.mtkView.delegate = self;
    self.mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    self.mtkView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.mtkView.clipsToBounds = YES;

}



#pragma mark - Interaction

- (void)updateIOWithTouchEvent:(UIEvent *)event
{
    UITouch *anyTouch = event.allTouches.anyObject;
    CGPoint touchLocation = [anyTouch locationInView:self.view];
    ImGuiIO &io = ImGui::GetIO();
    io.MousePos = ImVec2(touchLocation.x, touchLocation.y);

    BOOL hasActiveTouch = NO;
    for (UITouch *touch in event.allTouches)
    {
        if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled)
        {
            hasActiveTouch = YES;
            break;
        }
    }
    io.MouseDown[0] = hasActiveTouch;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

#pragma mark - MTKViewDelegate

- (void)drawInMTKView:(MTKView*)view
{
    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize.x = view.bounds.size.width;
    io.DisplaySize.y = view.bounds.size.height;

    CGFloat framebufferScale = view.window.screen.nativeScale ?: UIScreen.mainScreen.nativeScale;
    io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);
    io.DeltaTime = 1 / float(view.preferredFramesPerSecond ?: 60);
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
        
        if (MenDeal == true) 
        {
            [self.view setUserInteractionEnabled:YES];
            
        } 
        else if (MenDeal == false) 
        {
           
            [self.view setUserInteractionEnabled:NO];
           

        }

        MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
        if (renderPassDescriptor != nil)
        {
            id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
            [renderEncoder pushDebugGroup:@"ImGui Jane"];

            ImGui_ImplMetal_NewFrame(renderPassDescriptor);
            ImGui::NewFrame();
    CGFloat x = (([UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.width) - 380) / 2;
    CGFloat y = (([UIApplication sharedApplication].windows[0].rootViewController.view.frame.size.height) - 260) / 2;
     ImGui::SetNextWindowPos(ImVec2(x, y), ImGuiCond_FirstUseEver);
    ImGui::SetNextWindowSize(ImVec2(660, 400), ImGuiCond_FirstUseEver);
            if (MenDeal == true)
            {
                ImGuiWindowFlags flags = ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoNavInputs;
                ImGui::Begin(oxorany("Free Fire Menu - VinhTran"), &MenDeal, flags);
                ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(0.08f, 0.09f, 0.14f, 0.95f));
                ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.14f, 0.16f, 0.24f, 0.92f));
                ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.25f, 0.34f, 0.59f, 0.95f));
                ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImVec4(0.33f, 0.44f, 0.73f, 1.00f));
                ImGui::PushStyleVar(ImGuiStyleVar_FrameRounding, 16.0f);
                ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(18, 18));
                ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(12, 10));

                ImGui::BeginChild("##duck_sidebar", ImVec2(150, 0), true, ImGuiWindowFlags_NoScrollbar);
                ImGui::TextColored(DuckAccentColor, "DUCK UI");
                ImGui::TextDisabled("Native iOS style");
                ImGui::Dummy(ImVec2(0, 18));
                for (int i = 0; i < IM_ARRAYSIZE(DuckTabNames); i++) {
                    bool active = (DuckTabIndex == i);
                    if (active) {
                        ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.18f, 0.42f, 0.93f, 0.96f));
                        ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.24f, 0.52f, 0.98f, 0.95f));
                        ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImVec4(0.20f, 0.40f, 0.88f, 1.00f));
                    }
                    ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(14, 12));
                    if (ImGui::Button(DuckTabNames[i], ImVec2(-1, 48))) {
                        DuckTabIndex = i;
                    }
                    ImGui::PopStyleVar();
                    if (active) {
                        ImGui::PopStyleColor(3);
                    }
                    ImGui::Dummy(ImVec2(0, 12));
                }
                ImGui::Dummy(ImVec2(0, 10));
                ImGui::Separator();
                ImGui::Dummy(ImVec2(0, 10));
                ImGui::TextDisabled("v1.0");
                ImGui::TextDisabled("Tap to toggle");
                ImGui::EndChild();

                ImGui::SameLine();
                ImGui::BeginGroup();
                ImGui::BeginChild("##duck_main", ImVec2(0, 0), false, ImGuiWindowFlags_AlwaysUseWindowPadding);

                ImGui::BeginChild("##duck_header", ImVec2(0, 90), true, ImGuiWindowFlags_NoScrollbar);
                ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(1.0f, 1.0f, 1.0f, 0.04f));
                ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(1.0f, 1.0f, 1.0f, 0.08f));
                ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImVec4(1.0f, 1.0f, 1.0f, 0.10f));
                ImGui::PushStyleVar(ImGuiStyleVar_FrameRounding, 22.0f);
                ImGui::PushStyleVar(ImGuiStyleVar_FramePadding, ImVec2(12, 10));
                ImGui::BeginGroup();
                ImGui::BeginChild("##header_pill", ImVec2(0, 0), false, ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoBackground);
                ImGui::TextColored(DuckAccentColor, "  ●  ");
                ImGui::SameLine();
                ImGui::TextColored(ImVec4(1,1,1,0.95f), "MENU NATIVE IOS");
                ImGui::SameLine(); ImGui::Dummy(ImVec2(10,0));
                ImGui::SameLine(); ImGui::TextDisabled("— Objective-C inspired");
                ImGui::Dummy(ImVec2(0, 8));
                ImGui::TextWrapped("Modern control panel with rounded corners, blur-like dark glass finish and tab navigation.");
                ImGui::EndChild();
                ImGui::EndGroup();
                ImGui::PopStyleVar(2);
                ImGui::PopStyleColor(3);
                ImGui::EndChild();

                ImGui::Dummy(ImVec2(0, 10));
                ImGui::Separator();
                ImGui::Dummy(ImVec2(0, 10));

                if (DuckTabIndex == 0) {
                    ImGui::Text("ESP");
                    ImGui::Dummy(ImVec2(0,8));
                    ImGui::Checkbox(oxorany("Enable Cheats"), &Vars.Enable);
                    ImGui::Dummy(ImVec2(0,8));
                    if (ImGui::BeginTable("esp_table", 2, ImGuiTableFlags_SizingStretchSame | ImGuiTableFlags_NoBordersInBody)) {
                        ImGui::TableNextColumn(); ImGui::Checkbox(oxorany("Line"), &Vars.lines);
                        ImGui::TableNextColumn(); ImGui::Checkbox(oxorany("Box"), &Vars.Box);
                        ImGui::TableNextColumn(); ImGui::Checkbox(oxorany("Health"), &Vars.Health);
                        ImGui::TableNextColumn(); ImGui::Checkbox(oxorany("Name"), &Vars.Name);
                        ImGui::TableNextColumn(); ImGui::Checkbox(oxorany("Skeleton"), &Vars.skeleton);
                        ImGui::TableNextColumn(); ImGui::Checkbox(oxorany("Distance"), &Vars.Distance);
                        ImGui::TableNextColumn(); ImGui::Checkbox(oxorany("3D Circle"), &Vars.circlepos);
                        ImGui::TableNextColumn(); ImGui::Checkbox(oxorany("Outline"), &Vars.Outline);
                        ImGui::EndTable();
                    }
                    ImGui::Dummy(ImVec2(0, 12));
                    ImGui::Checkbox(oxorany("Out of Screen"), &Vars.OOF);
                    ImGui::SameLine(); ImGui::Checkbox(oxorany("Enemy Count"), &Vars.enemycount);
                }
                else if (DuckTabIndex == 1) {
                    ImGui::Text("AIMBOT");
                    ImGui::Dummy(ImVec2(0,8));
                    ImGui::Checkbox(oxorany("Enable Aimbot"), &Vars.Aimbot);
                    ImGui::Checkbox(oxorany("Silent Aim"), &Vars.SilentAim);
                    if (Vars.SilentAim) {
                        ImGui::Checkbox(oxorany("Silent Aim Wall Check"), &Vars.SilentAimCheckWall);
                        ImGui::Combo(oxorany("Silent Aim Hitbox"), &Vars.SilentAimHitbox, Vars.silentAimHitboxes, 2);
                    }
                    ImGui::Dummy(ImVec2(0, 12));
                    ImGui::Combo(oxorany("Aim When"), &Vars.AimWhen, Vars.dir, 4);
                    ImGui::Combo(oxorany("Aim Target"), &Vars.AimTarget, Vars.aimTargets, 3);
                    ImGui::Checkbox(oxorany("Ignore Downed"), &Vars.IgnoreDowned);
                    ImGui::Dummy(ImVec2(0, 10));
                    ImGui::SliderFloat(oxorany("Aim FOV"), &Vars.AimFov, 0.0f, 500.0f);
                    ImGui::Checkbox(oxorany("FOV Glow"), &Vars.fovaimglow);
                    if (Vars.fovaimglow) {
                        ImGui::ColorEdit4(oxorany("FOV Color"), Vars.fovLineColor);
                    }
                }
                else if (DuckTabIndex == 2) {
                    ImGui::Text("DEVELOPER INFO");
                    ImGui::Dummy(ImVec2(0,8));
                    ImGui::TextWrapped("Note: This is a free cheat for the game Free Fire. I am not responsible for any bans or other consequences that may occur from using this cheat.");
                    ImGui::Dummy(ImVec2(0, 8));
                    ImGui::TextWrapped("If you are banned, it is because you are using a cheat, not because of the developer.");
                    ImGui::Dummy(ImVec2(0, 8));
                    ImGui::TextWrapped("If you want to support the developer, you can buy me a coffee.");
                    ImGui::Dummy(ImVec2(0, 8));
                    ImGui::TextWrapped("Thank you for using my cheat.");
                    ImGui::Dummy(ImVec2(0, 8));
                    ImGui::TextWrapped("If you have any questions, you can contact me on discord: VinhTran#0001");
                }

                ImGui::Dummy(ImVec2(0, 16));
                ImGui::Separator();
                ImGui::Dummy(ImVec2(0, 8));
                ImGui::TextDisabled("Powered by native-style UI");
                ImGui::EndChild();
                ImGui::EndGroup();
                ImGui::PopStyleVar(3);
                ImGui::PopStyleColor(4);
                ImGui::End();
            }
            ImDrawList* draw_list = ImGui::GetBackgroundDrawList();
            static bool sdkInitialized = false;
            if (!sdkInitialized) {
                game_sdk->init();
                sdkInitialized = true;
            }
            get_players();
            draw_watermark();
            aimbot();
            if (Vars.AimFov > 0) {
                Vars.isAimFov = true;
            } else {
                Vars.isAimFov = false;
            }
            ImGui::Render();
            ImDrawData* draw_data = ImGui::GetDrawData();
            ImGui_ImplMetal_RenderDrawData(draw_data, commandBuffer, renderEncoder);
          
            [renderEncoder popDebugGroup];
            [renderEncoder endEncoding];

            [commandBuffer presentDrawable:view.currentDrawable];
        }

        [commandBuffer commit];
}

- (void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size
{
    
}

@end

