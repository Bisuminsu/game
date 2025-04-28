import pygame
import random

pygame.init()


# 화면 설정
WIDTH, HEIGHT = 800, 600
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Mini Maple Stage Game")

# 원하는 몬스터 크기 설정
MONSTER_WIDTH = 60
MONSTER_HEIGHT = 60

# 이미지 불러오기 + 크기 조절
monster1_img = pygame.image.load("monster1.webp").convert_alpha()
monster1_img = pygame.transform.smoothscale(monster1_img, (MONSTER_WIDTH, MONSTER_HEIGHT))

monster2_img = pygame.image.load("monster2.webp").convert_alpha()
monster2_img = pygame.transform.smoothscale(monster2_img, (MONSTER_WIDTH, MONSTER_HEIGHT))

monster3_img = pygame.image.load("monster3.webp").convert_alpha()
monster3_img = pygame.transform.smoothscale(monster3_img, (MONSTER_WIDTH, MONSTER_HEIGHT))

# 색상
WHITE = (255, 255, 255)
BLUE = (0, 0, 255)
GREEN = (0, 200, 0)
RED = (255, 0, 0)
BLACK = (0, 0, 0)
YELLOW = (255, 255, 0)

font = pygame.font.SysFont(None, 36)

# 캐릭터 설정
player_size = (40, 60)
player_pos = [100, 500]
player_speed = 5
player_jump_speed = -15
gravity = 0.8
velocity_y = 0
on_ground = False
player_hp = 100
damage_cooldown = 0



# 공격 관련
attack_cooldown = 0
attack_duration = 10
is_attacking = False
attack_rect = None
facing_right = True

# 스테이지
stage = 1
stage_clear = False
clear_timer = 0


# 몬스터 클래스 (이미지 & 방향 반전 포함)
class Monster:
    def __init__(self, x, y, type='normal'):
        self.rect = pygame.Rect(x, y, 60, 60)
        self.direction = random.choice([-1, 1])
        self.speed = 2
        self.type = type

        if type == 'normal':
            self.image = monster1_img
            self.damage = 5
        elif type == 'strong':
            self.image = monster2_img
            self.damage = 10
        elif type == 'elite':
            self.image = monster3_img
            self.damage = 20

    def update(self):
        self.rect.x += self.direction * self.speed
        if self.rect.left < 0 or self.rect.right > WIDTH:
            self.direction *= -1

    def draw(self, surface):
        # 방향에 따라 이미지 반전
        if self.type == 'normal':
            img = self.image if self.direction > 0 else pygame.transform.flip(self.image, True, False)
        else:  # strong, elite는 왼쪽 기준
            img = pygame.transform.flip(self.image, True, False) if self.direction > 0 else self.image

        surface.blit(img, self.rect)

# 몬스터 생성 함수 (랜덤 타입 부여)
def spawn_monsters(stage):
    new_monsters = []
    for _ in range(stage + 1):
        x = random.randint(100, 700)
        y = random.choice([510, 410, 310])
        # 타입 결정 (Stage가 높아질수록 강한 몬스터 등장 확률 증가)
        type_roll = random.randint(1, 100)
        if type_roll <= 60:
            type = 'normal'
        elif type_roll <= 90:
            type = 'strong'
        else:
            type = 'elite'
        new_monsters.append(Monster(x, y, type))
    return new_monsters



# 스테이지별 플랫폼 생성
def generate_platforms(stage):
    platforms = [
        pygame.Rect(0, 550, 800, 50)  # 항상 바닥 존재
    ]
    for _ in range(min(stage + 1, 5)):  # 스테이지에 따라 최대 5개까지 플랫폼
        x = random.randint(100, 700)
        y = random.randint(200, 500)
        width = random.randint(100, 200)
        platforms.append(pygame.Rect(x, y, width, 20))
    return platforms
platforms = generate_platforms(stage)  # 초기 맵 생성
if stage_clear:
    clear_timer -= 1
    if clear_timer <= 0:
        stage += 1
        monsters = spawn_monsters(stage)
        platforms = generate_platforms(stage)  # 새 플랫폼 생성!
        stage_clear = False

if clear_timer <= 0:
    stage += 1
    monsters = spawn_monsters(stage)
    platforms = generate_platforms(stage)  # 새로운 맵 생성!
    stage_clear = False
    
clock = pygame.time.Clock()

# 게임 루프
running = True
while running:
    screen.fill(WHITE)

    # 이벤트 처리
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    # 키 입력 처리
    keys = pygame.key.get_pressed()
    if keys[pygame.K_LEFT]:
        player_pos[0] -= player_speed
        facing_right = False
    if keys[pygame.K_RIGHT]:
        player_pos[0] += player_speed
        facing_right = True
    if keys[pygame.K_SPACE] and on_ground:
        velocity_y = player_jump_speed
        on_ground = False
    if keys[pygame.K_z] and attack_cooldown == 0:
        is_attacking = True
        attack_cooldown = 30
        if facing_right:
            attack_rect = pygame.Rect(player_pos[0] + player_size[0], player_pos[1] + 10, 30, 40)
        else:
            attack_rect = pygame.Rect(player_pos[0] - 30, player_pos[1] + 10, 30, 40)

    # 중력 적용
    player_pos[1] += velocity_y
    velocity_y += gravity

    # 캐릭터 Rect 갱신
    player_rect = pygame.Rect(player_pos[0], player_pos[1], *player_size)

    # 충돌 처리 - 플랫폼
    on_ground = False
    for platform in platforms:
        if player_rect.colliderect(platform) and velocity_y >= 0:
            player_pos[1] = platform.top - player_size[1]
            velocity_y = 0
            on_ground = True

    # 몬스터 업데이트 및 충돌 감지
    for monster in monsters[:]:
        monster.update()
        if player_rect.colliderect(monster.rect):
            if damage_cooldown == 0:
                player_hp -= monster.damage
                damage_cooldown = 60
                if player_hp <= 0:
                    running = False
        if is_attacking and attack_rect.colliderect(monster.rect):
            monsters.remove(monster)

    if damage_cooldown > 0:
        damage_cooldown -= 1

    # 공격 애니메이션 처리
    if is_attacking:
        attack_duration -= 1
        if attack_duration <= 0:
            is_attacking = False
            attack_duration = 10
            attack_rect = None
    if attack_cooldown > 0:
        attack_cooldown -= 1

    # 몬스터 모두 처치 시 Stage Clear
    if not monsters and not stage_clear:
        stage_clear = True
        clear_timer = 120  # 2초간 Clear 표시

    if stage_clear:
        clear_timer -= 1
        if clear_timer <= 0:
            stage += 1
            monsters = spawn_monsters(stage)
            stage_clear = False

    # 플랫폼 그리기
    for platform in platforms:
        pygame.draw.rect(screen, GREEN, platform)

    # 몬스터 그리기
    for monster in monsters:
        monster.draw(screen)

    # 캐릭터 기본 색상
    player_color = BLUE
    damage_flash = 0  # 데미지 후 색상 지속 시간
    
    # 캐릭터 그리기
    if damage_flash > 0:
        pygame.draw.rect(screen, RED, player_rect)  # 데미지 피드백
        damage_flash -= 1
    else:
        pygame.draw.rect(screen, player_color, player_rect)

    if player_rect.colliderect(monster.rect):
        if damage_cooldown == 0:
            player_hp -= monster.damage
            damage_cooldown = 60
            damage_flash = 15  # 빨간색 유지 프레임
            if player_hp <= 0:
                running = False

    # 공격 hitbox 그리기
    if is_attacking and attack_rect:
        pygame.draw.rect(screen, YELLOW, attack_rect)

    # HP & Stage 표시
    hp_text = font.render(f"HP: {player_hp}", True, BLACK)
    stage_text = font.render(f"Stage: {stage}", True, BLACK)
    screen.blit(hp_text, (10, 10))
    screen.blit(stage_text, (WIDTH - 150, 10))

    # Stage Clear 문구
    if stage_clear:
        clear_text = font.render("STAGE CLEAR!", True, BLACK)
        screen.blit(clear_text, (WIDTH // 2 - 100, HEIGHT // 2 - 20))

    pygame.display.flip()
    clock.tick(60)

# 게임 오버 화면
screen.fill(WHITE)
game_over_text = font.render("Game Over!", True, RED)
screen.blit(game_over_text, (WIDTH // 2 - 100, HEIGHT // 2 - 20))
pygame.display.flip()
pygame.time.wait(2000)
pygame.quit()
