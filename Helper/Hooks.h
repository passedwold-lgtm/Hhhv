#pragma once

#import "../oxorany/oxorany_include.h"
#import "../IMGUI/imgui.h"
#import "../IMGUI/imgui_internal.h"
#import "Mem.h"
#import "../Other/dobby_defines.h"
#import "Obfuscate.h"
#import "Vector3.h"
#import "Quaternion.h"
#import "Monostring.h"
#import "Vars.h"
#import "../Zexishook/hook.h"
#import "vinhtran.hpp"
#import "loading.hxx"
#include <vector>
#include <unordered_map>
#include <algorithm>
#include <cctype>
#include <fstream>
#include <chrono>
#include <cmath>
#include <cstdint>
#include <ctime>
enum FireMode { 
    MANUL,
    AUTO
}; 

enum FireStatus { 
    NONE,
    FIRING,
    CANCEL
};

static const float FireDelay = 0.1f;

struct HitObjectInfo {
    void *klass;
    void *monitor;
    bool m_IsInPool;
    void *HitObject;
    void *HitCollider;
    Vector3 HitLocation;
    Vector3 HitNormal;
    Vector3 RayDir;
    Vector3 StartPosition;
    int32_t Damage;
    float Distance;
    int32_t ActorLayer;
    int32_t HitGroup;
    void *HitPhysicMaterial;
    bool IgnoreHappens;
    bool ViewBlocked;
    struct Vector3 OrigStartPosition;
    uint8_t SpecialHitType;
    uint32_t SpecialHitLevelObjID;
};

extern ImFont* pixel_smol;

extern ImFont* verdana_smol;

class game_sdk_t;
extern game_sdk_t *game_sdk;

void initAutoFireHook();

#define FMT_HEADER_ONLY
#include "fmt/core.h"

class game_sdk_t
{
public:
    void init();
    int (*GetHp)(void *player);
    void *(*Curent_Match)();
    void *(*GetLocalPlayer)(void *Game);
    void *(*GetHeadPositions)(void *player);
    Vector3 (*get_position)(void *player);
    void *(*Component_GetTransform)(void *player);
    void *(*get_camera)();
    Vector3 (*WorldToViewpoint)(void*, Vector3, int);
    bool (*get_isVisible)(void *player);
    bool (*get_isLocalTeam)(void *player);
    bool (*get_IsDieing)(void *player);
    int (*get_MaxHP)(void *player);
    Vector3 (*GetForward)(void *player);
    void (*set_aim)(void *, Quaternion look);
    bool (*get_IsSighting)(void *player);
    bool (*get_IsFiring)(void *player);
    monoString *(*name)(void *player);
    void *(*_GetHeadPositions)(void *);
    void *(*_newHipMods)(void *);
    void *(*_GetLeftAnkleTF)(void *);
    void *(*_GetRightAnkleTF)(void *);
    void *(*_GetLeftToeTF)(void *);
    void *(*_GetRightToeTF)(void *);
    void *(*_getLeftHandTF)(void *);
    void *(*_getRightHandTF)(void *);
    void *(*_getLeftForeArmTF)(void *);
    void *(*_getRightForeArmTF)(void *);
};



inline bool isSdkReady() {
    return game_sdk &&
           game_sdk->Curent_Match != nullptr &&
           game_sdk->GetLocalPlayer != nullptr &&
           game_sdk->Component_GetTransform != nullptr &&
           game_sdk->get_position != nullptr;
}

void game_sdk_t::init()
{
    static bool sdk_initialized = false;
    if (sdk_initialized)
        return;
    sdk_initialized = true;

    this->GetHp = (int (*)(void *))getRealOffset(oxo("0x4A8478C"));
    this->Curent_Match = (void *(*)())getRealOffset(oxo("0x4E355B0"));
    this->GetLocalPlayer = (void *(*)(void *))getRealOffset(oxo("0x28FC854"));
    this->GetHeadPositions = (void *(*)(void *))getRealOffset(oxo("0x4AA1A28"));
    this->get_position = (Vector3(*)(void *))getRealOffset(oxo("0x8552BAC"));
    this->Component_GetTransform = (void *(*)(void *))getRealOffset(oxo("0x854060C"));
    this->get_camera = (void *(*)())getRealOffset(oxo("0x84E7148"));

    this->WorldToViewpoint = (Vector3(*)(void*, Vector3, int))getRealOffset(oxo("0x84E6AC8"));

    this->get_isVisible = (bool (*)(void *))getRealOffset(oxo("0x4A20AF4"));

    this->get_isLocalTeam = (bool (*)(void *))getRealOffset(oxo("0x4A38D90"));

    this->get_IsDieing = (bool (*)(void *))getRealOffset(oxo("0x4A02EA8"));

    this->get_MaxHP = (int (*)(void *))getRealOffset(oxo("0x4A8489C"));

    this->GetForward = (Vector3(*)(void *))getRealOffset(oxo("0x85534CC"));

    this->set_aim = (void (*)(void *, Quaternion))getRealOffset(oxo("0x4A1C91C"));

    this->get_IsSighting = (bool (*)(void *))getRealOffset(oxo("0x4A0FF18"));

    this->get_IsFiring = (bool (*)(void *))getRealOffset(oxo("0x4A05634"));

    this->name = (monoString * (*)(void *player)) getRealOffset(oxo("0x4A16D38"));

    this->_GetHeadPositions = (void *(*)(void *))getRealOffset(oxo("0x4AA1A28"));
    this->_newHipMods = (void *(*)(void *))getRealOffset(oxo("0x4AA1BD8"));
    this->_GetLeftAnkleTF = (void *(*)(void *))getRealOffset(oxo("0x4AA2028"));
    this->_GetRightAnkleTF = (void *(*)(void *))getRealOffset(oxo("0x4AA2134"));
    this->_GetLeftToeTF = (void *(*)(void *))getRealOffset(oxo("0x4AA2240"));
    this->_GetRightToeTF = (void *(*)(void *))getRealOffset(oxo("0x4AA234C"));
    this->_getLeftHandTF = (void *(*)(void *))getRealOffset(oxo("0x4A1B9B4"));
    this->_getRightHandTF = (void *(*)(void *))getRealOffset(oxo("0x4A1BAB8"));
    this->_getLeftForeArmTF = (void *(*)(void *))getRealOffset(oxo("0x4A1BBBC"));
    this->_getRightForeArmTF = (void *(*)(void *))getRealOffset(oxo("0x4A1BCC0"));
}

static void Transform_INTERNAL_SetPosition(void *transform, Vvector3 in) {
    void (*_Transform_INTERNAL_SetPosition)(void *transform, Vvector3 in) =
        (void (*)(void *, Vvector3))getRealOffset(oxo("0x8552CE8"));
    _Transform_INTERNAL_SetPosition(transform, in);
}
// 1. Dùng static để biến chỉ tồn tại trong file này, tránh xung đột
static float spinY = 0.0f; 

// 2. Hàm set góc xoay chuẩn
static void Transform_INTERNAL_SetRotation(void *transform, Vvector3 inn) {
    if (!transform) return;

    // Offset chuẩn từ dump của bạn cho set_localEulerAngles
    void (*_SetRot)(void *, Vvector3*) = (void (*)(void *, Vvector3*))getRealOffset(oxo("0x85530D0"));

    // QUAN TRỌNG: Truyền &inn (con trỏ) để phù hợp với kiến trúc ARM64 của game
    _SetRot(transform, &inn);
}

namespace Camera$$WorldToScreen {
    ImVec2 Checker(Vector3 pos, bool &checker);
}

class tanghinh {
public:
    static Vector3 Transform_GetPosition(void *player) {
       Vector3 out = Vector3::zero();
        void (*_Transform_GetPosition)(void *transform, Vector3 *out) = (void (*)(void *, Vector3 *))getRealOffset(oxo("0x8552C10"));
        _Transform_GetPosition(player, &out);
        return out;
    }

    static void *Player_GetHeadCollider(void *player)
    {
        void *(*_Player_GetHeadCollider)(void *players) = (void *(*)(void *))getRealOffset(oxo("0x4A1A9D4"));
        return _Player_GetHeadCollider(player);
    }

    static bool Physics_Raycast(Vector3 camLocation, Vector3 headLocation, unsigned int LayerID, void *collider)
    {
        bool (*_Physics_Raycast)(Vector3 camLocation, Vector3 headLocation, unsigned int LayerID, void *collider) = (bool (*)(Vector3, Vector3, unsigned int, void *))getRealOffset(oxo("0x5580870"));
        return _Physics_Raycast(camLocation, headLocation, LayerID, collider);
    }

    static bool isVisible(void *enemy) {
        if (enemy != NULL) {
            void *hitObj = NULL;
            auto Camera = Transform_GetPosition(game_sdk->Component_GetTransform(game_sdk->get_camera()));
            auto Target = Transform_GetPosition(game_sdk->Component_GetTransform(Player_GetHeadCollider(enemy)));
            return !Physics_Raycast(Camera, Target, 12, &hitObj);
        }
        return false;
    }
};

Vector3 getPosition(void *player);
Vector3 GetHeadPosition(void *player);

bool IsGod(void *player){
    return *(bool *)((uint64_t) player + 0xF4C);
}

void *get_gameObject(void *Pthis)
{
    return ((void* (*)(void *))getRealOffset(0x854065C))(Pthis);
}

static void *GetWeaponOnHand1(void *local) {
    void *(*_GetWeaponOnHand1)(void *local) = (void *(*)(void *))getRealOffset(0x4A16560);
    return _GetWeaponOnHand1(local);
}

static Vector3 Transform_INTERNAL_GetPosition(void *player) {
    Vector3 out = Vector3::zero();
    void (*_Transform_INTERNAL_GetPosition)(void *transform, Vector3 * out) = (void (*)(void *, Vector3 *))getRealOffset(ENCRYPTOFFSET("0x8552C10"));
    _Transform_INTERNAL_GetPosition(player, &out);
    return out;
}

void RotatePlayer360(void* player) {
    if (!player) return;

    // LẤY TRANSFORM: Đây là bước quan trọng nhất để không văng.
    // Hàm xoay 0x85530D0 YÊU CẦU Transform, không phải Player.
    void* transform = game_sdk->Component_GetTransform(player);
    
    // Kiểm tra vùng nhớ transform có hợp lệ không (tránh địa chỉ rác)
    if (!transform || (uintptr_t)transform < 0x10000000) return;

    // TỐC ĐỘ CON QUAY: 40.0f là xoay cực tít
    spinY += 40.0f;
    
    // Giữ góc luôn trong vòng 360 độ cho mượt
    if (spinY >= 360.0f) {
        spinY -= 360.0f;
    }

    Vvector3 rot;
    rot.X = 0.0f;
    rot.Y = spinY;
    rot.Z = 0.0f;

    // Gọi hàm thực thi
    Transform_INTERNAL_SetRotation(transform, rot);
}

namespace Camera$$WorldToScreen
{
ImVec2 Regular(Vector3 pos) {
    auto cam = game_sdk->get_camera();
    if (!cam) return {0,0};

    Vector3 worldPoint = game_sdk->WorldToViewpoint(cam,pos, 2);
    Vector3 location;

    int ScreenWidth = ImGui::GetIO().DisplaySize.x;
    int ScreenHeight = ImGui::GetIO().DisplaySize.y;

    location.x = ScreenWidth * worldPoint.x;
    location.y = ScreenHeight - worldPoint.y * ScreenHeight;
    location.z  = worldPoint.z;

    return {location.x, location.y};
}

ImVec2 Checker(Vector3 pos, bool &checker) {
    auto cam = game_sdk->get_camera();
    if (!cam) return {0, 0};
   
    Vector3 worldPoint = game_sdk->WorldToViewpoint(cam,pos, 4);
    Vector3 location;
 
    int ScreenWidth = ImGui::GetIO().DisplaySize.x;
    int ScreenHeight = ImGui::GetIO().DisplaySize.y;
 
    location.x = ScreenWidth * worldPoint.x;
    location.y = ScreenHeight - worldPoint.y * ScreenHeight;
    location.z = worldPoint.z;
 
    checker = location.z > 1;
 
    return {location.x, location.y};
}
}

Vector3 GetBonePosition(void *player, void *(*transformGetter)(void *)) {
    if (!player || !transformGetter)
        return Vector3();
    void *transform = transformGetter(player);
    return transform ? game_sdk->get_position(game_sdk->Component_GetTransform(transform)) : Vector3();
}

Vector3 GetHitboxPosition(void* player, int hitbox) {
    if (!player) return Vector3::zero();
    
    switch (hitbox) {
        case 0:
            return GetBonePosition(player, game_sdk->GetHeadPositions);
        case 1: {
            Vector3 headPos = GetBonePosition(player, game_sdk->GetHeadPositions);
            return headPos == Vector3::zero() ? headPos : Vector3(headPos.x, headPos.y - 0.15f, headPos.z);
        }
        case 2: {
            Vector3 headPos = GetBonePosition(player, game_sdk->GetHeadPositions);
            return headPos == Vector3::zero() ? headPos : Vector3(headPos.x, headPos.y - 0.4f, headPos.z);
        }
        default:
            return GetBonePosition(player, game_sdk->GetHeadPositions);
    }
}

Vector3 GetAimTargetPosition(void *player) {
    return GetHitboxPosition(player, Vars.AimTarget);
}

Vector3 getPosition(void *player) {
    return game_sdk->get_position(game_sdk->Component_GetTransform(player));
}

Vector3 GetHeadPosition(void *player) {
    return game_sdk->get_position(game_sdk->GetHeadPositions(player));
}

static Vector3 CameraMain(void *player) {
    return game_sdk->get_position(*(void **)((uint64_t)player + oxo("0x390")));//public Transform MainCameraTransform;
}

Quaternion GetRotationToTheLocation(Vector3 Target, float Height, Vector3 MyEnemy) {
    Vector3 direction = (Target + Vector3(0, Height, 0)) - MyEnemy;
    return Quaternion::LookRotation(direction, Vector3(0, 1, 0));
}

Quaternion GetCurrentRotation(void* player) {
    void* transform = game_sdk->Component_GetTransform(player);
    if (!transform) return Quaternion();
    return Quaternion::LookRotation(game_sdk->GetForward(transform), Vector3(0, 1, 0));
}

static Vector3 lastNinjaRunPos = Vector3::zero();
static bool lastNinjaWasActive = false;

void SetNinjaRunSpeedPreset(int preset) {
    switch (preset) {
        case 0: Vars.NinjaRunSpeed = 0.5f; break;
        case 1: Vars.NinjaRunSpeed = 1.0f; break;
        case 2: Vars.NinjaRunSpeed = 2.5f; break;
        case 3: Vars.NinjaRunSpeed = 5.0f; break;
        default: break;
    }
}

void RunNinjaRun() {
    if (!Vars.Enable || !Vars.NinjaRun)
        return;

    void* match = game_sdk->Curent_Match();
    if (!match) return;

    void* local = game_sdk->GetLocalPlayer(match);
    if (!local) return;

    void* transform = game_sdk->Component_GetTransform(local);
    if (!transform) return;

    Vector3 currentPos = game_sdk->get_position(transform);
    Vector3 forward = game_sdk->GetForward(transform);
    float moveAmount = Vars.NinjaRunSpeed * 0.1f;

    currentPos.x += forward.x * moveAmount;
    currentPos.y += forward.y * moveAmount;
    currentPos.z += forward.z * moveAmount;
    currentPos.y += Vars.NinjaRunHeight * 0.01f;

    lastNinjaRunPos = currentPos;
    lastNinjaWasActive = true;

    Vvector3 newPos;
    newPos.X = currentPos.x;
    newPos.Y = currentPos.y;
    newPos.Z = currentPos.z;
    Transform_INTERNAL_SetPosition(transform, newPos);
}

// Static variables để track Telekill delay
static auto lastTelekillTime = std::chrono::high_resolution_clock::now();
static int telekillCount = 0;

void RunTelekill2() {
    if (!Vars.Enable || !Vars.RunTelekill)
        return;

    auto now = std::chrono::high_resolution_clock::now();
    auto elapsed = std::chrono::duration_cast<std::chrono::milliseconds>(now - lastTelekillTime).count();
    if (elapsed < 100) return;
    lastTelekillTime = now;

    void *match = game_sdk->Curent_Match();
    if (!match) return;

    void *local = game_sdk->GetLocalPlayer(match);
    if (!local || !game_sdk->Component_GetTransform(local)) return;

    Dictionary<uint8_t *, void **> *players = *(Dictionary<uint8_t *, void **> **)((long)match + oxo("0x148"));
    if (!players || !players->getValues().empty()) return;

    void *localTF = game_sdk->Component_GetTransform(local);
    Vector3 localPos = game_sdk->get_position(localTF);
    Vector3 forward = game_sdk->GetForward(localTF);

    telekillCount = 0;
    const int MAX_TELEPORT_PER_FRAME = 3;

    for (int i = 0; i < players->getSize(); i++) {
        if (telekillCount >= MAX_TELEPORT_PER_FRAME) break;

        void *enemy = players->getValues()[i];
        if (!enemy || enemy == local) continue;
        if (!game_sdk->Component_GetTransform(enemy)) continue;
        if (!game_sdk->get_MaxHP(enemy)) continue;
        if (game_sdk->get_IsDieing(enemy)) continue;
        if (game_sdk->get_isLocalTeam(enemy)) continue;

        void *enemyTF = game_sdk->Component_GetTransform(enemy);
        Vector3 enemyPos = game_sdk->get_position(enemyTF);
        float distance = Vector3::Distance(localPos, enemyPos);

        if (distance > Vars.TelekillDistance)
            continue;

        if (Vars.TelekillSpeed < 1.0f) {
            Vector3 pullDirection = Vector3::Normalized(localPos - enemyPos);
            float pullDistance = distance * Vars.TelekillSpeed * 0.05f;
            enemyPos = enemyPos + pullDirection * pullDistance;
        }

        float offsetAngle = (telekillCount * 120.0f) * 3.14159f / 180.0f;
        Vector3 offsetPos = Vector3(
            cosf(offsetAngle) * 1.5f,
            0.3f,
            sinf(offsetAngle) * 1.5f
        );

        Vector3 stableFront = localPos + forward * 1.2f + offsetPos;
        stableFront.y = localPos.y + 0.2f;

        Transform_INTERNAL_SetPosition(enemyTF, Vvector3(stableFront.x, stableFront.y, stableFront.z));
        telekillCount++;
    }
}

#include "Helper/Ext.h"


void DrawSkeleton(void *player, ImDrawList *drawList)
{
    if (!player || !drawList)
        return;
    bool isPlayerVisible = tanghinh::isVisible(player);
    Vector3 headPos = GetBonePosition(player, game_sdk->_GetHeadPositions);
    Vector3 hipPos = GetBonePosition(player, game_sdk->_newHipMods);
    Vector3 leftAnklePos = GetBonePosition(player, game_sdk->_GetLeftAnkleTF);
    Vector3 rightAnklePos = GetBonePosition(player, game_sdk->_GetRightAnkleTF);
    Vector3 leftToePos = GetBonePosition(player, game_sdk->_GetLeftToeTF);
    Vector3 rightToePos = GetBonePosition(player, game_sdk->_GetRightToeTF);
    Vector3 leftHandPos = GetBonePosition(player, game_sdk->_getLeftHandTF);
    Vector3 rightHandPos = GetBonePosition(player, game_sdk->_getRightHandTF);
    Vector3 leftForeArmPos = GetBonePosition(player, game_sdk->_getLeftForeArmTF);
    Vector3 rightForeArmPos = GetBonePosition(player, game_sdk->_getRightForeArmTF);

    // Chuyển đổi vị trí xương sang tọa độ màn hình
    bool visible;
    ImVec2 headScreen = Camera$$WorldToScreen::Checker(headPos, visible);
    if (!visible)
        return;

    ImVec2 hipScreen = Camera$$WorldToScreen::Regular(hipPos);
    ImVec2 leftAnkleScreen = Camera$$WorldToScreen::Regular(leftAnklePos);
    ImVec2 rightAnkleScreen = Camera$$WorldToScreen::Regular(rightAnklePos);
    ImVec2 leftToeScreen = Camera$$WorldToScreen::Regular(leftToePos);
    ImVec2 rightToeScreen = Camera$$WorldToScreen::Regular(rightToePos);
    ImVec2 leftHandScreen = Camera$$WorldToScreen::Regular(leftHandPos);
    ImVec2 rightHandScreen = Camera$$WorldToScreen::Regular(rightHandPos);
    ImVec2 leftForeArmScreen = Camera$$WorldToScreen::Regular(leftForeArmPos);
    ImVec2 rightForeArmScreen = Camera$$WorldToScreen::Regular(rightForeArmPos);
    ImColor boneColor = isPlayerVisible ? ImColor(0, 255, 0) : ImColor(255, 255, 255);
    float thickness = 1.0f;

    // Vẽ đầu
    drawList->AddCircle(headScreen, 2.0f, boneColor, 12, thickness);
    // Vẽ thân
    drawList->AddLine(headScreen, hipScreen, boneColor, thickness);
    // Vẽ tay
    drawList->AddLine(headScreen, leftForeArmScreen, boneColor, thickness);
    drawList->AddLine(headScreen, rightForeArmScreen, boneColor, thickness);
    drawList->AddLine(leftForeArmScreen, leftHandScreen, boneColor, thickness);
    drawList->AddLine(rightForeArmScreen, rightHandScreen, boneColor, thickness);
    // Vẽ chân
    drawList->AddLine(hipScreen, leftAnkleScreen, boneColor, thickness);
    drawList->AddLine(hipScreen, rightAnkleScreen, boneColor, thickness);
    drawList->AddLine(leftAnkleScreen, leftToeScreen, boneColor, thickness);
    drawList->AddLine(rightAnkleScreen, rightToeScreen, boneColor, thickness);
}

bool isFov(Vector3 vec1, Vector3 vec2, int radius)
{
    int x = vec1.x;
    int y = vec1.y;
    int x0 = vec2.x;
    int y0 = vec2.y;
    if ((pow(x - x0, 2) + pow(y - y0, 2)) <= pow(radius, 2))
    {
        return true;
    }
    return false;
}

void *GetClosestEnemy()
{
    try
    {
        float shortestDistance = 9999.0f;
        void *closestEnemy = NULL;
        void *get_MatchGame = game_sdk->Curent_Match();
        if (!get_MatchGame)
            return NULL;
        void *LocalPlayer = game_sdk->GetLocalPlayer(get_MatchGame);
        if (!LocalPlayer || !game_sdk->Component_GetTransform(LocalPlayer))
            return NULL;
        if (!Vars.Enable)
            return NULL;
        Dictionary<uint8_t *, void **> *players = *(Dictionary<uint8_t *, void **> **)((long)get_MatchGame + oxo("0x148"));
        if (!players )
            return NULL;
        for (int u = 0; u < players->getSize(); u++)
        {
            void *Player = players->getValues()[u];
            if (!Player)
                continue;
            if (Player == LocalPlayer)
                continue;
            if (!game_sdk->get_MaxHP(Player))
                continue;
            if (Vars.IgnoreDowned && game_sdk->get_IsDieing(Player))
                continue;
            if (!Vars.SilentAim && !game_sdk->get_isVisible(Player))
                continue;
            if (game_sdk->get_isLocalTeam(Player))
                continue;
            Vector3 PlayerPos = getPosition(Player);
            Vector3 LocalPlayerPos = getPosition(LocalPlayer);
            ImVec2 screenPos = Camera$$WorldToScreen::Regular(PlayerPos);
            bool isFov1 = isFov(Vector3(screenPos.x, screenPos.y), Vector3(ImGui::GetIO().DisplaySize.x / 2, ImGui::GetIO().DisplaySize.y / 2), Vars.AimFov);
            float distance = Vector3::Distance(LocalPlayerPos, PlayerPos);
            if (distance < 200)
            {
                Vector3 targetDir = Vector3::Normalized(PlayerPos - LocalPlayerPos);
                float angle = Vector3::Angle(targetDir, game_sdk->GetForward(game_sdk->Component_GetTransform(game_sdk->get_camera()))) * 100.0f;
                if (angle <= Vars.AimFov && isFov1 && angle < shortestDistance)
                {
                    if (Vars.SilentAim || tanghinh::isVisible(Player))
                    {
                        shortestDistance = angle;
                        closestEnemy = Player;
                    }
                }
            }
        }
        return closestEnemy;
    }
    catch (...)
    {
        return NULL;
    }
}

void *GetClosestEnemysilent()
{
    try
    {
        float shortestDistance = 99999.0f;
        void *closestEnemy = NULL;

        void *get_MatchGame = game_sdk->Curent_Match();
        if (!get_MatchGame)
            return NULL;

        void *LocalPlayer = game_sdk->GetLocalPlayer(get_MatchGame);
        if (!LocalPlayer || !game_sdk->Component_GetTransform(LocalPlayer))
            return NULL;

        if (!Vars.Enable)
            return NULL;

        Dictionary<uint8_t *, void **> *players = *(Dictionary<uint8_t *, void **> **)((long)get_MatchGame + oxo("0x148"));
        if (!players)
            return NULL;

        ImVec2 screenSize = ImGui::GetIO().DisplaySize;
        ImVec2 center(screenSize.x / 2, screenSize.y / 2);

        for (int i = 0; i < players->getSize(); i++) {
            void *Player = players->getValues()[i];
            if (!Player || Player == LocalPlayer)
                continue;
            if (!game_sdk->get_MaxHP(Player))
                continue;
            if (game_sdk->get_IsDieing(Player))
                continue;
            if (game_sdk->get_isLocalTeam(Player))
                continue;
            if (IsGod(Player))
                continue;
            int hp = game_sdk->GetHp(Player);
            if (Vars.IgnoreDowned && hp <= 0)
                continue;

            bool isInsideCamera = false;
            Vector3 pos = getPosition(Player);
            ImVec2 screenPos = Camera$$WorldToScreen::Checker(pos, isInsideCamera);
            if (!isInsideCamera)
                continue;
            if (screenPos.x < 0 || screenPos.x > screenSize.x ||
                screenPos.y < 0 || screenPos.y > screenSize.y)
                continue;

            if (Vars.SilentAimCheckWall)
            {
                if (!game_sdk->get_isVisible(Player))
                    continue;
                if (!tanghinh::isVisible(Player))
                    continue;
            }

            float dx = screenPos.x - center.x;
            float dy = screenPos.y - center.y;
            float screenDist = sqrtf(dx * dx + dy * dy);

            if (screenDist < shortestDistance)
            {
                shortestDistance = screenDist;
                closestEnemy = Player;
            }
        }

        return closestEnemy;
    }
    catch (...)
    {
        return NULL;
    }
}

void *getItransform(void *itransform) {
    void * (*_itransformNode)(void *_this) = (void*(*)(void*))getRealOffset(0x5C52CFC);
    return _itransformNode(itransform);
}

static float get_Range(void *pthis)
{
    return ((float (*)(void *))getRealOffset(ENCRYPTOFFSET("0x4E8703C")))(pthis);
}

bool isEnemyInRangeWeapon(void *player, void *enemy, void* weapon)
{
    if (player != nullptr && enemy != nullptr && weapon != nullptr)
    {
        Vector3 EnemyHeadPosition = GetHeadPosition(enemy);
        Vector3 PlayerHeadPosition = GetHeadPosition(player);
        float distance = Vector3::Distance(PlayerHeadPosition, EnemyHeadPosition);
        float range = get_Range(weapon);

        if (distance <= range) {
            return true;
        }
    }
    return false;
}

Vector3 GetHipPosition(void* player) {
    void *HipITF= *(void **)((uint64_t) player + oxo("0x648"));
    void *HipTF = getItransform(HipITF);
    Vector3 Hip = Transform_INTERNAL_GetPosition(HipTF);
    return Hip;
}

int (*old_BLAGCMCGEJG1)(void *, HitObjectInfo *);
int BLAGCMCGEJG1(void *ist, HitObjectInfo *HitObject) {
    if (Vars.SilentAim && HitObject) {
        void *match = game_sdk->Curent_Match();
        if (match) {
            void *localPlayer = game_sdk->GetLocalPlayer(match);
            if (localPlayer) {
                void *weapon = GetWeaponOnHand1(localPlayer);
                void *enemy = GetClosestEnemysilent();
                if (enemy && weapon) {
                    if (isEnemyInRangeWeapon(localPlayer, enemy, weapon)) {
                        Vector3 enemyPos;
                        if (Vars.SilentAimHitbox == 0)
                            enemyPos = GetHeadPosition(enemy);
                        else
                            enemyPos = GetHipPosition(enemy);
                        Vector3 startPos = GetHeadPosition(localPlayer);
                        HitObject->HitObject = get_gameObject(tanghinh::Player_GetHeadCollider(enemy));
                        HitObject->HitCollider = tanghinh::Player_GetHeadCollider(enemy);
                        HitObject->HitLocation = enemyPos;
                        HitObject->HitNormal = enemyPos;
                        HitObject->RayDir = Vector3::Normalized(enemyPos - startPos);
                        HitObject->StartPosition = startPos;
                        HitObject->OrigStartPosition = startPos;
                        HitObject->HitGroup = 1;
                        HitObject->SpecialHitType = 0;
                        HitObject->IgnoreHappens = false;
                        HitObject->ViewBlocked = false;
                    }
                }
            }
        }
    }

    return old_BLAGCMCGEJG1(ist, HitObject);
}

void *GetClosestEnemy360(void *local_player, void *match)
{
    if (!local_player || !match) return NULL;

    Vector3 localPos = getPosition(local_player);
    void *bestTarget = NULL;
    float bestPriority = -9999.0f;

    Dictionary<uint8_t *, void **> *players = *(Dictionary<uint8_t *, void **> **)((long)match + oxo("0x148"));
    if (!players)
        return NULL;

    for (int u = 0; u < players->getSize(); u++) {
        void *enemy = players->getValues()[u];
        if (!enemy || enemy == local_player || !game_sdk->Component_GetTransform(enemy) ||
            !game_sdk->get_MaxHP(enemy) || game_sdk->get_isLocalTeam(enemy))
            continue;
        if (game_sdk->get_IsDieing(enemy))
            continue;
        bool visible = tanghinh::isVisible(enemy);
        if (Vars.Aim360PrioritizeVisible && !visible && !Vars.SilentAim)
            continue;

        Vector3 enemyPos = getPosition(enemy);
        float distance = Vector3::Distance(localPos, enemyPos);
        if (distance > Vars.Aim360Radius)
            continue;

        float priority = 1000.0f / (distance + 1.0f);
        if (visible) priority *= 2.0f;
        if (game_sdk->GetHp(enemy) < 50) priority *= 1.5f;

        if (priority > bestPriority) {
            bestPriority = priority;
            bestTarget = enemy;
        }
    }

    return bestTarget;
}

void ProcessAimbot360()
{
    if (!Vars.Enable || !Vars.Aimbot)
        return;

    void *match = game_sdk->Curent_Match();
    if (!match) return;

    void *local_player = game_sdk->GetLocalPlayer(match);
    if (!local_player || !game_sdk->Component_GetTransform(local_player)) return;

    bool IsFiring = game_sdk->get_IsFiring(local_player);
    bool IsScopeOn = game_sdk->get_IsSighting(local_player);
    bool shouldAim =
        (Vars.AimWhen == 0) ||
        (Vars.AimWhen == 1 && IsFiring) ||
        (Vars.AimWhen == 2 && IsScopeOn);
    if (!shouldAim)
        return;

    void *target = GetClosestEnemy360(local_player, match);
    if (!target) return;

    Vector3 targetPos = GetHitboxPosition(target, Vars.AimTarget);
    Vector3 cameraPos = CameraMain(local_player);
    if (targetPos == Vector3::zero() || cameraPos == Vector3::zero()) return;

    Quaternion aimRot = GetRotationToTheLocation(targetPos, 0.05f, cameraPos);
    game_sdk->set_aim(local_player, aimRot);
}



void *GetClosestEnemy180(void *local_player, void *match)
{
    if (!local_player || !match) return NULL;

    Vector3 localPos = getPosition(local_player);
    void *camera = game_sdk->get_camera();
    if (!camera) return NULL;

    Vector3 forward = game_sdk->GetForward(game_sdk->Component_GetTransform(camera));
    void *bestTarget = NULL;
    float bestPriority = -9999.0f;

    Dictionary<uint8_t *, void **> *players = *(Dictionary<uint8_t *, void **> **)((long)match + oxo("0x148"));
    if (!players)
        return NULL;

    for (int u = 0; u < players->getSize(); u++) {
        void *enemy = players->getValues()[u];
        if (!enemy || enemy == local_player || !game_sdk->Component_GetTransform(enemy) ||
            !game_sdk->get_MaxHP(enemy) || game_sdk->get_isLocalTeam(enemy))
            continue;
        if (game_sdk->get_IsDieing(enemy))
            continue;
        bool visible = tanghinh::isVisible(enemy);
        if (Vars.Aim180FrontOnly && !visible && !Vars.SilentAim)
            continue;

        Vector3 enemyPos = getPosition(enemy);
        Vector3 direction = Vector3::Normalized(enemyPos - localPos);
        float dot = Vector3::Dot(forward, direction);
        dot = std::clamp(dot, -1.0f, 1.0f);
        float angle = acosf(dot) * 57.29577951308232f;
        if (angle > Vars.Aim180Angle * 0.5f)
            continue;

        float distance = Vector3::Distance(localPos, enemyPos);
        float priority = 1000.0f / (distance + 1.0f);
        if (visible) priority *= 2.0f;

        if (priority > bestPriority) {
            bestPriority = priority;
            bestTarget = enemy;
        }
    }

    return bestTarget;
}

void ProcessAimbot180()
{
    if (!Vars.Enable || !Vars.Aimbot)
        return;

    void *match = game_sdk->Curent_Match();
    if (!match) return;

    void *local_player = game_sdk->GetLocalPlayer(match);
    if (!local_player || !game_sdk->Component_GetTransform(local_player)) return;

    bool IsFiring = game_sdk->get_IsFiring(local_player);
    bool IsScopeOn = game_sdk->get_IsSighting(local_player);
    bool shouldAim =
        (Vars.AimWhen == 0) ||
        (Vars.AimWhen == 1 && IsFiring) ||
        (Vars.AimWhen == 2 && IsScopeOn);
    if (!shouldAim)
        return;

    void *target = GetClosestEnemy180(local_player, match);
    if (!target) return;

    Vector3 targetPos = GetHitboxPosition(target, Vars.AimTarget);
    Vector3 cameraPos = CameraMain(local_player);
    if (targetPos == Vector3::zero() || cameraPos == Vector3::zero()) return;

    Quaternion aimRot = GetRotationToTheLocation(targetPos, 0.05f, cameraPos);
    game_sdk->set_aim(local_player, aimRot);
}

void ProcessAimbot()
{
    if (!Vars.Aimbot || !isSdkReady())
        return;
    void *CurrentMatch = game_sdk->Curent_Match();
    if (!CurrentMatch)
        return;
    void *LocalPlayer = game_sdk->GetLocalPlayer(CurrentMatch);
    if (!LocalPlayer || !game_sdk->Component_GetTransform(LocalPlayer))
        return;
    if (game_sdk->get_IsDieing(LocalPlayer))
        return;

    if (Vars.AimType == 1) {
        ProcessAimbot360();
        return;
    }

    if (Vars.AimType == 2) {
        ProcessAimbot180();
        return;
    }

    void *closestEnemy = GetClosestEnemy();
    if (!closestEnemy || !game_sdk->Component_GetTransform(closestEnemy))
        return;
    if (game_sdk->get_IsDieing(closestEnemy))
        return;
    if (!Vars.SilentAim && !game_sdk->get_isVisible(closestEnemy))
        return;
    Vector3 EnemyLocation = GetAimTargetPosition(closestEnemy);
    if (EnemyLocation == Vector3::zero())
        return;
    Vector3 PlayerLocation = CameraMain(LocalPlayer);
    if (PlayerLocation == Vector3::zero())
        return;
    Quaternion PlayerLook = GetRotationToTheLocation(EnemyLocation, 0.1f, PlayerLocation);

    bool IsScopeOn = game_sdk->get_IsSighting(LocalPlayer);
    bool IsFiring = game_sdk->get_IsFiring(LocalPlayer);

    bool shouldAim =
        (Vars.AimWhen == 0) ||
        (Vars.AimWhen == 1 && IsFiring) ||
        (Vars.AimWhen == 2 && IsScopeOn);

    if (shouldAim)
    {
        game_sdk->set_aim(LocalPlayer, PlayerLook);
    }
}

void UpOneEnemy() {
    if (!Vars.Enable || !Vars.UpPlayerOne)
        return;

    void *match = game_sdk->Curent_Match();
    if (!match) return;

    void *local = game_sdk->GetLocalPlayer(match);
    if (!local || !game_sdk->Component_GetTransform(local)) return;

    Dictionary<uint8_t *, void **> *players = *(Dictionary<uint8_t *, void **> **)((long)match + oxo("0x148"));
    if (!players || players->getValues().empty()) return;

    Vector3 localPos = game_sdk->get_position(game_sdk->Component_GetTransform(local));

    for (int i = 0; i < players->getSize(); i++) {
        void *enemy = players->getValues()[i];
        if (!enemy || enemy == local) continue;
        if (!game_sdk->Component_GetTransform(enemy)) continue;
        if (!game_sdk->get_MaxHP(enemy)) continue;
        if (game_sdk->get_IsDieing(enemy)) continue;
        if (game_sdk->get_isLocalTeam(enemy)) continue;

        void *enemyTF = game_sdk->Component_GetTransform(enemy);
        Vector3 enemyPos = game_sdk->get_position(enemyTF);
        float distance = Vector3::Distance(localPos, enemyPos);
        if (distance <= 10.0f) continue;

        float targetY = enemyPos.y + 5.7f;
        float step = 0.35f;

        if (enemyPos.y < targetY - 0.1f)
            enemyPos.y += step;
        else if (enemyPos.y > targetY + 0.1f)
            enemyPos.y -= step;

        Transform_INTERNAL_SetPosition(enemyTF, Vvector3(enemyPos.x, enemyPos.y, enemyPos.z));
    }
}

void RunUpPlayer2() {
    if (!Vars.Enable || !Vars.RunUpPlayer)
        return;

    void *match = game_sdk->Curent_Match();
    if (!match) return;

    void *local = game_sdk->GetLocalPlayer(match);
    if (!local || !game_sdk->Component_GetTransform(local)) return;

    Dictionary<uint8_t *, void **> *players = *(Dictionary<uint8_t *, void **> **)((long)match + oxo("0x148"));
    if (!players || players->getValues().empty()) return;

    Vector3 localPos = game_sdk->get_position(game_sdk->Component_GetTransform(local));

    for (int i = 0; i < players->getSize(); i++) {
        void *enemy = players->getValues()[i];
        if (!enemy || enemy == local) continue;
        if (!game_sdk->Component_GetTransform(enemy)) continue;
        if (!game_sdk->get_MaxHP(enemy)) continue;
        if (game_sdk->get_IsDieing(enemy)) continue;
        if (game_sdk->get_isLocalTeam(enemy)) continue;

        void *enemyTF = game_sdk->Component_GetTransform(enemy);
        Vector3 enemyPos = game_sdk->get_position(enemyTF);
        float distance = Vector3::Distance(localPos, enemyPos);
        if (distance <= 10.0f) continue;

        float targetY = enemyPos.y + 5.7f;
        float step = 0.90f;

        if (enemyPos.y < targetY - 0.1f)
            enemyPos.y += step;

        Transform_INTERNAL_SetPosition(enemyTF, Vvector3(enemyPos.x, enemyPos.y, enemyPos.z));
    }
}

void get_players()
{
    ImDrawList *draw_list = ImGui::GetBackgroundDrawList();
    if (!draw_list)
        return;

    if (!isSdkReady())
        return;

    initAutoFireHook();

    if (!Vars.Enable && !Vars.enemycount)
        return;

    try
    {
        if (Vars.Enable) {
            ProcessAimbot();

            if (Vars.UpPlayerOne) {
                UpOneEnemy();
            }
            if (Vars.NinjaRun) {
                RunNinjaRun();
            }
            if (Vars.RunUpPlayer) {
                RunUpPlayer2();
            }
            if (Vars.RunTelekill) {
                RunTelekill2();
            }
        }

        void *current_Match = game_sdk->Curent_Match();
        if (!current_Match)
            return;

        void *local_player = game_sdk->GetLocalPlayer(current_Match);
        if (!local_player)
            return;

        if (Vars.Rotate360) {
            RotatePlayer360(local_player);
        }

        Dictionary<uint8_t *, void **> *players = *(Dictionary<uint8_t *, void **> **)((long)current_Match + 0x148);
        if (!players )
            return;

        int playerCount = players->getSize();
        bool localIncluded = false;
        for (int i = 0; i < players->getSize(); i++) {
            if (players->getValues()[i] == local_player) {
                localIncluded = true;
                break;
            }
        }
        if (!localIncluded && local_player) {
            playerCount += 1;
        }

        if (Vars.enemycount) {
            std::string countText = fmt::format("Players: {}", playerCount);
            draw_list->AddText(ImVec2(12, 12), IM_COL32(255, 255, 255, 255), countText.c_str());
        }

        void *camera = game_sdk->get_camera();
        if (!camera)
            return;

        for (int u = 0; u < players->getSize(); u++)
        {
            void *closestEnemy = players->getValues()[u];
            if (!closestEnemy)
                continue;
            if (!game_sdk->Component_GetTransform(closestEnemy))
                continue;
            if (closestEnemy == local_player)
                continue;
            if (!game_sdk->get_MaxHP(closestEnemy))
                continue;
            if (Vars.IgnoreDowned && game_sdk->get_IsDieing(closestEnemy))
                continue;
            if (!game_sdk->get_isVisible(closestEnemy))
                continue;
            if (game_sdk->get_isLocalTeam(closestEnemy))
                continue;

            Vector3 pos = getPosition(closestEnemy);
            Vector3 pos2 = getPosition(local_player);
            float distance = Vector3::Distance(pos, pos2);
            if (distance > 200.0f)
                continue;
            ImColor line_color = ImColor(255, 255, 255);
            bool w2sc;
            ImVec2 top_pos = Camera$$WorldToScreen::Regular(pos + Vector3(0, 1.6, 0));
            ImVec2 bot_pos = Camera$$WorldToScreen::Regular(pos);
            ImVec2 pos_3 = Camera$$WorldToScreen::Checker(pos, w2sc);
            auto pmtXtop = top_pos.x;
            auto pmtXbottom = bot_pos.x;
            if (top_pos.x > bot_pos.x)
            {
                pmtXtop = bot_pos.x;
                pmtXbottom = top_pos.x;
            }
            Camera$$WorldToScreen::Checker(pos + Vector3(0, 0.75f, 0), w2sc);
            float calculatedPosition = fabs((top_pos.y - bot_pos.y) * (0.0092f / 0.019f) / 2);

            ImRect rect(
                ImVec2(pmtXtop - calculatedPosition, top_pos.y),
                ImVec2(pmtXbottom + calculatedPosition, bot_pos.y));
            const auto &viewpos = game_sdk->get_position(game_sdk->Component_GetTransform(game_sdk->get_camera()));
        

if (w2sc)
{
    bool isDying   = game_sdk->get_IsDieing(closestEnemy);
    ImColor themeColor = ImColor(Vars.themeColor.x, Vars.themeColor.y, Vars.themeColor.z, Vars.themeColor.w);
    ImColor boxColor   = isDying ? ImColor(255, 0, 0) : themeColor;
    ImColor lineColor  = isDying ? ImColor(255, 0, 0) : themeColor;
    float thickness   = Vars.EspBorderThickness;

   
    float baseFontSize  = 8.f;
    float scaleFactor   = std::clamp(distance / Vars.EspScaleSpeed, Vars.EspScaleMin, Vars.EspScaleMax);
    float fontSize      = baseFontSize * scaleFactor;
    
    if (Vars.lines)
    {
        draw_list->AddLine(
            ImVec2(ImGui::GetIO().DisplaySize.x / 2, 0),
            ImVec2(rect.GetCenter().x, rect.Min.y),
            lineColor,
            thickness
        );
    }

 
    auto pname = game_sdk->name(closestEnemy);
    std::string names = "null";
    if (pname) names = pname->toCPPString();
    std::transform(names.begin(), names.end(), names.begin(), ::tolower);

    std::string diststr = fmt::format("{}M", static_cast<int>(distance));

    // Số random stable per enemy
    static int   cachedRandNum = rand() % 10;
    static void* lastEnemy     = nullptr;
    if (lastEnemy != closestEnemy)
    {
        lastEnemy      = closestEnemy;
        cachedRandNum  = rand() % 10;
    }
    std::string numstr = fmt::format("{}", cachedRandNum);

    // HP
    std::string healthStr = "";
    if (Vars.Health)
    {
        auto health = game_sdk->GetHp(closestEnemy);
        healthStr   = fmt::format("{}", static_cast<int>(health));
    }

   
    ImVec2 num_size  = verdana_smol->CalcTextSizeA(fontSize, FLT_MAX, 0, numstr.c_str());
    ImVec2 name_size = verdana_smol->CalcTextSizeA(fontSize, FLT_MAX, 0, names.c_str());
    ImVec2 dist_size = verdana_smol->CalcTextSizeA(fontSize, FLT_MAX, 0, diststr.c_str());

    float padding = 5.f;
    float gap     = 8.f;
    float infoH   = num_size.y + 4.f; // chiều cao tự động theo font

    // infoW = tổng width các text + padding
    float totalTextW = num_size.x + gap + name_size.x + gap + dist_size.x;
    float infoW      = std::max(rect.GetWidth(), totalTextW + padding * 2);

    // Căn giữa info rect với box
    float infoX = rect.GetCenter().x - infoW / 2.f;
    float infoY = rect.Min.y - infoH - 4.f; // trên health bar

   
    draw_list->AddRectFilled(
        ImVec2(infoX,         infoY),
        ImVec2(infoX + infoW, infoY + infoH),
        ImColor(0, 0, 0, 210)
    );
    draw_list->AddRect(
        ImVec2(infoX,         infoY),
        ImVec2(infoX + infoW, infoY + infoH),
        ImColor(60, 60, 60, 255)
    );

    float textY    = infoY + (infoH - num_size.y) / 2.f;
    float currentX = infoX + padding;

    // Số (xanh lá, trái)
    AddText(verdana_smol, fontSize, false, false,
        ImVec2(currentX, textY),
        ImColor(0, 255, 0), numstr);
    currentX += num_size.x + gap;

    // Tên (vàng, giữa) - căn giữa tuyệt đối
    if (Vars.Name)
    {
        float nameX = infoX + (infoW / 2.f) - (name_size.x / 2.f);
        AddText(verdana_smol, fontSize, false, false,
            ImVec2(nameX, textY),
            ImColor(255, 215, 0), names);
    }

    // Distance (cam, phải)
    if (Vars.Distance)
    {
        float distX = infoX + infoW - dist_size.x - padding;
        AddText(verdana_smol, fontSize, false, false,
            ImVec2(distX, textY),
            ImColor(255, 165, 0), diststr);
    }

    
    if (Vars.Health)
    {
        auto  health    = game_sdk->GetHp(closestEnemy);
        auto  maxhealth = game_sdk->get_MaxHP(closestEnemy);
        float ratio     = std::clamp((float)health / (float)maxhealth, 0.f, 1.f);

        float barX = infoX;             // cùng width với info rect
        float barW = infoW;
        float barY = infoY + infoH;     // ngay sát dưới info rect
        float barH = 3.f;

        // Nền đen
        draw_list->AddRectFilled(
            ImVec2(barX,        barY),
            ImVec2(barX + barW, barY + barH),
            ImColor(0, 0, 0, 180)
        );

        // Fill HP
        ImColor hpColor = (ratio > 0.5f) ? ImColor(0, 255, 0)
                        : (ratio > 0.25f)? ImColor(255, 165, 0)
                        :                  ImColor(255, 0,   0);

        draw_list->AddRectFilled(
            ImVec2(barX,                barY),
            ImVec2(barX + barW * ratio, barY + barH),
            hpColor
        );
    }


    if (Vars.Box)
    {
        draw_list->AddRect(rect.Min, rect.Max, boxColor, 0, 0, Vars.EspBorderThickness);

        if (Vars.Outline)
        {
            draw_list->AddRect(rect.Min - ImVec2(1,1), rect.Max + ImVec2(1,1),
                               ImColor(0,0,0), 0, 0, 1.f);
            draw_list->AddRect(rect.Min + ImVec2(1,1), rect.Max - ImVec2(1,1),
                               ImColor(0,0,0), 0, 0, 1.f);
        }
    }

    if (Vars.circlepos)
        Draw3DCircle(pos, 1.0f, 0.5f, ImColor(255, 0, 0), 36, false, 0.5f);

    if (Vars.skeleton)
        DrawSkeleton(closestEnemy, draw_list);
}
            if (Vars.OOF)
            {
                if ((pos_3.x < 0 || pos_3.x > disp.width) || (pos_3.y < 0 || pos_3.y > disp.height) || !w2sc)
                {
                    constexpr int maxpixels = 150;
                    int pixels = maxpixels;
                    if (w2sc)
                    {
                        if (pos_3.x < 0)
                            pixels = std::clamp((int)-pos_3.x, 0, (int)maxpixels);
                        if (pos_3.y < 0)
                            pixels = std::clamp((int)-pos_3.y, 0, (int)maxpixels);

                        if (pos_3.x > disp.width)
                            pixels = std::clamp((int)pos_3.x - (int)disp.width, 0, (int)maxpixels);
                        if (pos_3.y > disp.height)
                            pixels = std::clamp((int)pos_3.y - (int)disp.height, 0, (int)maxpixels);
                    }

                    float opacity = (float)pixels / (float)maxpixels;

                    float size = 3.5f;
                    Vector3 viewdir = game_sdk->GetForward(game_sdk->Component_GetTransform(game_sdk->get_camera()));
                    Vector3 targetdir = Vector3::Normalized(pos - viewpos);

                    float viewangle = atan2(viewdir.z, viewdir.x) * Rad2Deg;
                    float targetangle = atan2(targetdir.z, targetdir.x) * Rad2Deg;

                    if (viewangle < 0)
                        viewangle += 360;
                    if (targetangle < 0)
                        targetangle += 360;

                    float angle = targetangle - viewangle;

                    while (angle < 0)
                        angle += 360;
                    while (angle > 360)
                        angle -= 360;

                    angle = 360 - angle;
                    angle -= 90;
                    OtFovV1(ImGui::GetIO().DisplaySize.x / 2, ImGui::GetIO().DisplaySize.y / 2, 90 + distance * 2,
                            angle - size,
                            angle + size,
                            ImColor(1.f, 1.f, 1.f, 1.f * opacity), 1);
                }
            }
        }
    }
    catch (...)
    {
        return;
    }
}
void (*_AutoFire)(void *_this, int32_t pFireStatus, int32_t pFireMode);

void old_AutoFire(void *_this, int32_t pFireStatus, int32_t pFireMode) 
{
    static clock_t lastTime = 0;
    static bool fireState = false;

    if (_this != NULL) 
    {
        if (Vars.AutoFire) 
        {
            clock_t now = clock();

            if ((float)(now - lastTime) / CLOCKS_PER_SEC >= FireDelay)
            {
                fireState = !fireState;  
                lastTime = now;
            }

            if (fireState)
                pFireStatus = FireStatus::FIRING;
            else
                pFireStatus = FireStatus::NONE;

            pFireMode = FireMode::AUTO;
        }
    }

    return _AutoFire(_this, pFireStatus, pFireMode);
}
void aimbot()
{
    ImVec2 center = ImVec2(ImGui::GetIO().DisplaySize.x / 2, ImGui::GetIO().DisplaySize.y / 2);
    if (!Vars.Aimbot || !isSdkReady())
        return;
    ImDrawList *draw_list = ImGui::GetBackgroundDrawList();
    if (!draw_list)
        return;
    void *Match = game_sdk->Curent_Match();
    if (!Match)
        return;
    if (Vars.isAimFov)
    {
        if (Vars.fovaimglow)
            drawcircleglow(draw_list, center, Vars.AimFov, ImColor(Vars.fovLineColor[0], Vars.fovLineColor[1], Vars.fovLineColor[2], Vars.fovLineColor[3]), 999, 1, 12);
        else
            draw_list->AddCircle(center, Vars.AimFov, ImColor(Vars.fovLineColor[0], Vars.fovLineColor[1], Vars.fovLineColor[2], Vars.fovLineColor[3]), 100);
    }
    void *LocalPlayer = game_sdk->GetLocalPlayer(Match);
    if (!LocalPlayer)
        return;
    void *playertarget = GetClosestEnemy();
    if (!playertarget)
        return;
    ImVec2 EnemyLocation = Camera$$WorldToScreen::Regular(GetAimTargetPosition(playertarget));
    drawlineglow(draw_list, ImVec2(center.x, center.y), EnemyLocation, ImColor(255, 255, 255), 1, 3);
}
void draw_watermark()
{
    std::string claw = oxorany("FREE FIRE");
    ImVec2 text_size = verdana_smol->calc_size(16, claw);
    ImVec2 text_pos(
        10, // Left margin
        ImGui::GetIO().DisplaySize.y - text_size.y - 10); // Bottom margin
    AddText(verdana_smol, 16, false, false, text_pos + ImVec2(1, 1), ImColor(0, 0, 0, 150), claw);
    static float hue = 0.0f;
    hue += ImGui::GetIO().DeltaTime * 0.1f;
    if (hue > 1.0f)
        hue = 0.0f;
    ImColor rainbow = ImColor::HSV(hue, 0.8f, 0.8f);
    AddText(verdana_smol, 16, false, false, text_pos, rainbow, claw);
    ImDrawList *draw_list = ImGui::GetBackgroundDrawList();
    draw_list->AddLine(
        ImVec2(text_pos.x, text_pos.y + text_size.y + 2),
        ImVec2(text_pos.x + text_size.x, text_pos.y + text_size.y + 2),
        rainbow,
        2.0f);
}