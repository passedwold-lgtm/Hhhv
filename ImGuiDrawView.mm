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
static int DuckTabIndex = 1; // Default to AIMBOT (Index 1)
static const char* DuckTabNames[] = {"ESP", "AIMBOT", "INFO"};
static const ImVec4 DuckAccentColor = ImVec4(1.00f, 0.62f, 0.00f, 1.0f); // Orange accent

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];

    if (!self.device) abort();

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;

    ImGui::StyleColorsDark();
    auto& Style = ImGui::GetStyle();
    
    // UI Style matching the reference image
    Style.WindowPadding = ImVec2(0.0f, 0.0f); // No padding for main window to allow sidebar
    Style.FramePadding = ImVec2(12.0f, 10.0f);
    Style.ItemSpacing = ImVec2(10.0f, 12.0f);
    Style.ItemInnerSpacing = ImVec2(10.0f, 8.0f);
    Style.GrabRounding = 12.0f;
    Style.FrameRounding = 30.0f; // Very rounded frames like in image
    Style.WindowRounding = 30.0f; // Very rounded window
    Style.ChildRounding = 30.0f;
    Style.PopupRounding = 15.0f;
    Style.ScrollbarRounding = 10.0f;
    
    ImVec4* colors = ImGui::GetStyle().Colors;
    colors[ImGuiCol_WindowBg] = ImVec4(0.06f, 0.05f, 0.03f, 1.00f); // Dark background
    colors[ImGuiCol_Border] = ImVec4(0.10f, 0.08f, 0.05f, 1.00f);
    colors[ImGuiCol_ChildBg] = ImVec4(0.00f, 0.00f, 0.00f, 0.00f); // Transparent child
    colors[ImGuiCol_FrameBg] = ImVec4(0.10f, 0.08f, 0.05f, 1.00f); // Item background
    colors[ImGuiCol_FrameBgHovered] = ImVec4(0.15f, 0.12f, 0.08f, 1.00f);
    colors[ImGuiCol_FrameBgActive] = ImVec4(0.20f, 0.15f, 0.10f, 1.00f);
    colors[ImGuiCol_TitleBg] = ImVec4(0.06f, 0.05f, 0.03f, 1.00f);
    colors[ImGuiCol_TitleBgActive] = ImVec4(0.06f, 0.05f, 0.03f, 1.00f);
    colors[ImGuiCol_CheckMark] = DuckAccentColor;
    colors[ImGuiCol_SliderGrab] = DuckAccentColor;
    colors[ImGuiCol_SliderGrabActive] = DuckAccentColor;
    colors[ImGuiCol_Button] = ImVec4(0.10f, 0.08f, 0.05f, 1.00f);
    colors[ImGuiCol_ButtonHovered] = ImVec4(0.15f, 0.12f, 0.08f, 1.00f);
    colors[ImGuiCol_ButtonActive] = ImVec4(0.20f, 0.15f, 0.10f, 1.00f);
    colors[ImGuiCol_Header] = ImVec4(1.00f, 0.62f, 0.00f, 0.20f);
    colors[ImGuiCol_HeaderHovered] = ImVec4(1.00f, 0.62f, 0.00f, 0.40f);
    colors[ImGuiCol_HeaderActive] = ImVec4(1.00f, 0.62f, 0.00f, 0.60f);
    colors[ImGuiCol_Text] = ImVec4(1.00f, 1.00f, 1.00f, 1.00f);
    colors[ImGuiCol_Separator] = ImVec4(0.10f, 0.08f, 0.05f, 1.00f);

    ImFont* font = io.Fonts->AddFontFromMemoryTTF(sansbold, sizeof(sansbold), 16.0f, NULL, io.Fonts->GetGlyphRangesCyrillic());
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
            [renderEncoder pushDebugGroup:@"ImGui Draw"];

            ImGui_ImplMetal_NewFrame(renderPassDescriptor);
            ImGui::NewFrame();

            if (MenDeal == true)
            {
                ImGui::SetNextWindowSize(ImVec2(480, 420), ImGuiCond_FirstUseEver);
                ImGuiWindowFlags flags = ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoScrollbar;
                
                ImGui::Begin("Main Menu", &MenDeal, flags);
                
                // --- SIDEBAR ---
                ImGui::BeginChild("Sidebar", ImVec2(70, 0), true, ImGuiWindowFlags_NoScrollbar);
                ImGui::SetCursorPosY(20);
                
                const char* sidebarIcons[] = {"(O)", "(+)", "[G]", "{S}", "|||"};
                for (int i = 0; i < 5; i++) {
                    ImGui::PushID(i);
                    bool active = (DuckTabIndex == (i < 3 ? i : 0)); // Map to existing tabs
                    if (active) {
                        ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0,0,0,0));
                        ImGui::PushStyleColor(ImGuiCol_Text, DuckAccentColor);
                        ImGui::PushStyleVar(ImGuiStyleVar_FrameBorderSize, 2.0f);
                        ImGui::PushStyleColor(ImGuiCol_Border, DuckAccentColor);
                    } else {
                        ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0,0,0,0));
                        ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.4f, 0.4f, 0.4f, 1.0f));
                        ImGui::PushStyleVar(ImGuiStyleVar_FrameBorderSize, 0.0f);
                    }
                    
                    if (ImGui::Button(sidebarIcons[i], ImVec2(45, 45))) {
                        if (i < 3) DuckTabIndex = i;
                    }
                    
                    ImGui::PopStyleColor(2);
                    if (active) ImGui::PopStyleColor();
                    ImGui::PopStyleVar();
                    
                    ImGui::Dummy(ImVec2(0, 15));
                    ImGui::PopID();
                }
                ImGui::EndChild();
                
                ImGui::SameLine(0, 0);
                
                // --- MAIN CONTENT ---
                ImGui::BeginGroup();
                ImGui::BeginChild("MainContent", ImVec2(0, 0), false, ImGuiWindowFlags_AlwaysUseWindowPadding);
                
                // Header
                ImGui::SetCursorPos(ImVec2(20, 20));
                ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(0.10f, 0.08f, 0.05f, 1.00f));
                ImGui::PushStyleVar(ImGuiStyleVar_ChildRounding, 20.0f);
                ImGui::BeginChild("HeaderTitle", ImVec2(150, 40), true);
                ImGui::SetCursorPos(ImVec2(10, 10));
                ImGui::TextColored(DuckAccentColor, "(+)  AIMBOT");
                ImGui::EndChild();
                ImGui::PopStyleVar();
                ImGui::PopStyleColor();
                
                ImGui::SameLine(ImGui::GetWindowWidth() - 140);
                ImGui::PushStyleVar(ImGuiStyleVar_FrameRounding, 20.0f);
                if (ImGui::Button("[v]", ImVec2(35, 35))) {} ImGui::SameLine();
                if (ImGui::Button("(M)", ImVec2(35, 35))) {} ImGui::SameLine();
                if (ImGui::Button(" X ", ImVec2(35, 35))) { MenDeal = false; }
                ImGui::PopStyleVar();
                
                ImGui::Dummy(ImVec2(0, 20));
                
                // Tab Content
                ImGui::Indent(10);
                if (DuckTabIndex == 0) { // ESP
                    ImGui::TextColored(DuckAccentColor, "ESP FEATURES");
                    ImGui::Separator();
                    ImGui::Spacing();
                    ImGui::Checkbox(oxorany("Enable ESP"), &Vars.Enable);
                    ImGui::Checkbox(oxorany("Line"), &Vars.lines);
                    ImGui::Checkbox(oxorany("Box"), &Vars.Box);
                    ImGui::Checkbox(oxorany("Health"), &Vars.Health);
                    ImGui::Checkbox(oxorany("Name"), &Vars.Name);
                }
                else if (DuckTabIndex == 1) { // AIMBOT
                    // Custom rounded list items
                    auto draw_menu_item = [&](const char* label, bool* var) {
                        ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(0.10f, 0.08f, 0.05f, 1.00f));
                        ImGui::PushStyleVar(ImGuiStyleVar_ChildRounding, 30.0f);
                        ImGui::BeginChild(label, ImVec2(ImGui::GetContentRegionAvail().x - 10, 55), true);
                        ImGui::SetCursorPos(ImVec2(20, 18));
                        ImGui::Text("%s", label);
                        ImGui::SameLine(ImGui::GetWindowWidth() - 50);
                        ImGui::SetCursorPosY(14);
                        ImGui::Checkbox("##", var);
                        ImGui::EndChild();
                        ImGui::PopStyleVar();
                        ImGui::PopStyleColor();
                        ImGui::Spacing();
                    };

                    draw_menu_item("Enable Aimbot", &Vars.Aimbot);
                    draw_menu_item("Aimsilent", &Vars.SilentAim);
                    draw_menu_item("Show Extra Animation", &Vars.circlepos);
                    draw_menu_item("Aim Kill", &Vars.IgnoreDowned);
                    
                    ImGui::SetCursorPosX(25);
                    ImGui::TextColored(DuckAccentColor, "To turn on Aim Kill fast, select HEADv2 below");
                    ImGui::Spacing();
                    
                    draw_menu_item("AutoFire", &Vars.enemycount);
                }
                else if (DuckTabIndex == 2) { // INFO
                    ImGui::TextColored(DuckAccentColor, "INFORMATION");
                    ImGui::Separator();
                    ImGui::Spacing();
                    ImGui::TextWrapped("Free Fire Menu - VinhTran\nVersion: 2.0\nStatus: Undetected");
                }
                
                ImGui::EndChild();
                ImGui::EndGroup();
                
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
            
            Vars.isAimFov = (Vars.AimFov > 0);
            
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
