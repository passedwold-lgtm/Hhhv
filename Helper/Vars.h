#pragma once

#import "../IMGUI/imgui.h"

struct Vars_t
{
    bool Enable = {};
    bool Aimbot = {};
    float AimFov = {};
    int AimCheck = {};
    int AimType = {};
    int AimTarget = {};
    int AimWhen = {};
    bool isAimFov = {};
    const char *dir[4] = {"Always", "Fire", "Scope", "Fire + Scope"};
    const char *aimTargets[3] = {"Head", "Neck", "Belly"};
    const char *aimModes[3] = {"AimFOV", "Aim360", "Aim180"};
    float Aim360Radius = 200.0f;
    bool Aim360PrioritizeVisible = true;
    float Aim180Angle = 180.0f;
    bool Aim180FrontOnly = true;
    bool lines = {};
    bool Box = {};
    bool Outline = {};
    bool Name = {};
    bool Health = {};
    bool Distance = {};
    bool fovaimglow = {};
    bool circlepos = {};
    bool skeleton = {};
    bool OOF = {};
    bool SpeedX2 = {};
    bool RapidFire = false;
    bool AutoFire = false;
    bool NoRecoil = false;
    bool NinjaRun = {};
    float NinjaRunSpeed = 1.0f;
    float NinjaRunHeight = 0.0f;
    bool Rotate360 = false;
    float RotateSpeed = 20.0f;
    bool UpPlayerOne = {};
    bool RunUpPlayer = {};
    bool RunTelekill = {};
    float TelekillDistance = 20.0f;
    float TelekillSpeed = 1.0f;
    bool enemycount = {};
    bool IgnoreDowned = {};
    bool SilentAim = false;
    bool SilentAimCheckWall = false;
    int SilentAimHitbox = 0;
    const char *silentAimHitboxes[2] = {"Head", "Hip"};
    float fovLineColor[4] = {1.0f, 1.0f, 1.0f, 1.0f};
    ImVec4 boxColor = ImVec4(1.0f, 1.0f, 1.0f, 1.0f);
    ImVec4 themeColor = ImVec4(0.43f, 0.55f, 0.98f, 1.0f);
    float EspScaleSpeed = 50.0f;
    float EspScaleMin = 0.8f;
    float EspScaleMax = 2.5f;
    float EspBorderThickness = 1.0f;
    float AimSpeed = 1.0f;
};

inline Vars_t Vars;
