"""Script tổng lực tạo bộ Sprite Chibi v2 và toàn bộ biểu cảm theo yêu cầu yeucau_sua_sprite_v2.md.
Chạy: tools\\.venv-art\\Scripts\\python.exe tools/art/generate_all_sprites_v2.py
"""
import os
import sys
import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.append(os.path.join(ROOT, "tools", "art"))
import make_expressions
from make_expressions import Face, FACES, RECIPES, SS

CHARS = os.path.join(ROOT, "game", "assets", "art", "chars")
SHOTS = os.path.join(ROOT, "build", "shots")
os.makedirs(SHOTS, exist_ok=True)

DARK_LINE = (43, 27, 23, 255)

# Thêm alias công thức biểu cảm
RECIPES["smirk"] = RECIPES["smug"]
RECIPES["sparkle"] = RECIPES["love"]
RECIPES["soft"] = RECIPES["love"]
RECIPES["awkward"] = RECIPES["flustered"]
RECIPES["smile"] = RECIPES["happy"]
RECIPES["stunned"] = RECIPES["shock"]
RECIPES["serious"] = RECIPES["think"]

def clean_alpha_border(im):
    arr = np.array(im)
    alpha = arr[:, :, 3]
    ys, xs = np.where(alpha > 10)
    if len(ys) == 0:
        return im
    y0, y1 = ys.min(), ys.max() + 1
    x0, x1 = xs.min(), xs.max() + 1
    cropped = im.crop((x0, y0, x1, y1))
    
    W, H = im.size
    out = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    paste_x = (W - cropped.width) // 2
    paste_y = H - cropped.height
    out.paste(cropped, (paste_x, paste_y), cropped)
    return out

def get_pure_apron():
    m = Image.open(os.path.join(CHARS, "m_front.png")).convert("RGBA")
    arr = np.array(m)
    apron = arr[222:435, 30:148].copy()
    
    for y in range(0, 65):
        for dx in range(1, 48):
            sx = 58 + dx
            tx = 58 - dx
            if sx < apron.shape[1] and tx >= 0:
                apron[y, tx] = apron[y, sx]
                
    r, g, b, a = apron[:,:,0], apron[:,:,1], apron[:,:,2], apron[:,:,3]
    is_not_apron = (r > 130) & (g > 105) & (b > 85) & (abs(r.astype(int)-g.astype(int)) > 10)
    apron[is_not_apron] = 0
    
    for y in range(0, 65):
        for x in range(0, 22):
            apron[y, x] = 0
        for x in range(95, apron.shape[1]):
            apron[y, x] = 0
            
    for y in range(95, 125):
        for x in range(75, 96):
            if apron[y, x, 3] == 0:
                apron[y, x] = [68, 50, 42, 255]
                
    im = Image.fromarray(apron)
    d = ImageDraw.Draw(im)
    d.line([(22, 10), (95, 10)], fill=DARK_LINE, width=2)
    return im

def build_duc_apron():
    print("1/8: duc_apron")
    duc = Image.open(os.path.join(CHARS, "duc_stand.png")).convert("RGBA")
    apron = get_pure_apron()
    res = duc.copy()
    res.alpha_composite(apron, (81, 228))
    d = ImageDraw.Draw(res)
    d.line([(103, 212), (103, 238)], fill=(55, 40, 34, 255), width=6)
    d.line([(100, 212), (100, 238)], fill=DARK_LINE, width=1)
    d.line([(106, 212), (106, 238)], fill=DARK_LINE, width=1)
    d.line([(173, 212), (173, 238)], fill=(55, 40, 34, 255), width=6)
    d.line([(170, 212), (170, 238)], fill=DARK_LINE, width=1)
    d.line([(176, 212), (176, 238)], fill=DARK_LINE, width=1)
    
    px0, py0, pw, ph = 56, 302, 26, 38
    pts = [(px0+4, py0), (px0+pw-2, py0+2), (px0+pw, py0+ph), (px0+2, py0+ph)]
    d.polygon(pts, fill=(215, 222, 228, 255))
    d.polygon([(px0+pw//2, py0+1), (px0+pw-2, py0+2), (px0+pw, py0+ph), (px0+pw//2+2, py0+ph)], fill=(160, 170, 180, 255))
    d.line([(px0+7, py0+4), (px0+6, py0+ph-4)], fill=(250, 252, 255, 255), width=2)
    d.polygon([(px0+2, py0), (px0-4, py0-3), (px0+6, py0+5)], fill=(225, 232, 238, 255), outline=DARK_LINE)
    d.polygon(pts, outline=DARK_LINE)
    d.arc([px0+pw-4, py0+7, px0+pw+9, py0+ph-7], start=270, end=90, fill=DARK_LINE, width=3)
    return clean_alpha_border(res)

def build_kyky_apron():
    print("2/8: kyky_apron")
    kyky = Image.open(os.path.join(CHARS, "kyky_hug.png")).convert("RGBA")
    arr = np.array(kyky)
    r, g, b, a = arr[:,:,0], arr[:,:,1], arr[:,:,2], arr[:,:,3]
    is_shirt = (a > 200) & (r < 75) & (g < 75) & (b < 75) & (np.arange(kyky.height)[:, None] >= 175) & (np.arange(kyky.height)[:, None] <= 280) & (np.arange(kyky.width)[None, :] >= 50) & (np.arange(kyky.width)[None, :] <= 145)
    lum = 0.299*r + 0.587*g + 0.114*b
    is_body = is_shirt & (lum >= 25)
    is_shadow = is_body & (lum < 45)
    is_light = is_body & (lum >= 45)
    arr[is_light, :3] = [248, 246, 242]
    arr[is_shadow, :3] = [220, 215, 210]
    
    res = Image.fromarray(arr)
    apron = get_pure_apron()
    w = int(apron.width * 0.85)
    h = int(apron.height * 0.85)
    apron_k = apron.resize((w, h), Image.LANCZOS)
    res.alpha_composite(apron_k, (55, 225))
    
    d = ImageDraw.Draw(res)
    d.line([(76, 205), (76, 235)], fill=(55, 40, 34, 255), width=5)
    d.line([(133, 205), (133, 235)], fill=(55, 40, 34, 255), width=5)
    
    tray_box = [36, 248, 150, 308]
    d.rounded_rectangle(tray_box, radius=6, fill=(196, 144, 92, 255), outline=DARK_LINE, width=2)
    d.rounded_rectangle([39, 251, 147, 305], radius=4, outline=(155, 105, 60, 255), width=1)
    
    cup_box = [75, 260, 115, 298]
    d.ellipse(cup_box, fill=(252, 250, 248, 255), outline=DARK_LINE, width=2)
    d.ellipse([79, 263, 111, 295], fill=(92, 52, 32, 255))
    d.polygon([(95, 291), (86, 280), (86, 275), (95, 281), (104, 275), (104, 280)], fill=(255, 255, 255, 255))
    d.ellipse([84, 273, 94, 282], fill=(255, 255, 255, 255))
    d.ellipse([96, 273, 106, 282], fill=(255, 255, 255, 255))
    
    res_arr = np.array(res)
    k_arr = np.array(kyky)
    is_hand_l = (k_arr[:,:,0] > 190) & (k_arr[:,:,1] > 140) & (k_arr[:,:,2] > 120) & (np.arange(kyky.height)[:, None] >= 240) & (np.arange(kyky.height)[:, None] <= 300) & (np.arange(kyky.width)[None, :] <= 50)
    is_hand_r = (k_arr[:,:,0] > 190) & (k_arr[:,:,1] > 140) & (k_arr[:,:,2] > 120) & (np.arange(kyky.height)[:, None] >= 235) & (np.arange(kyky.height)[:, None] <= 290) & (np.arange(kyky.width)[None, :] >= 110)
    is_hand = is_hand_l | is_hand_r
    res_arr[is_hand] = k_arr[is_hand]
    return clean_alpha_border(Image.fromarray(res_arr))

def build_duc_shirt():
    print("3/8: duc_shirt")
    duc = Image.open(os.path.join(CHARS, "duc_stand.png")).convert("RGBA")
    res = duc.copy()
    d = ImageDraw.Draw(res)
    d.polygon([(140, 206), (133, 178), (147, 178)], fill=(245, 205, 185, 255))
    d.line([(133, 178), (140, 206)], fill=DARK_LINE, width=2)
    d.line([(147, 178), (140, 206)], fill=DARK_LINE, width=2)
    d.polygon([(132, 178), (112, 195), (134, 214), (138, 204)], fill=(28, 25, 24, 255), outline=DARK_LINE)
    d.polygon([(148, 178), (168, 195), (146, 214), (142, 204)], fill=(28, 25, 24, 255), outline=DARK_LINE)
    d.line([(140, 206), (138, 355)], fill=DARK_LINE, width=2)
    for by in [225, 255, 285, 315, 345]:
        d.ellipse([137, by-2, 141, by+2], fill=(95, 90, 88, 255), outline=DARK_LINE)
        
    d.rounded_rectangle([48, 282, 80, 298], radius=3, fill=(38, 34, 32, 255), outline=DARK_LINE, width=2)
    d.line([(48, 290), (80, 290)], fill=(55, 50, 48, 255), width=1)
    d.rounded_rectangle([200, 282, 232, 298], radius=3, fill=(38, 34, 32, 255), outline=DARK_LINE, width=2)
    d.line([(200, 290), (232, 290)], fill=(55, 50, 48, 255), width=1)
    
    d.rectangle([204, 323, 218, 332], fill=(22, 20, 18, 255), outline=DARK_LINE, width=1)
    d.ellipse([207, 321, 217, 331], fill=(225, 230, 235, 255), outline=DARK_LINE, width=1)
    d.ellipse([209, 323, 215, 329], fill=(255, 255, 255, 255))
    return clean_alpha_border(res)

def build_kyky_dress():
    print("4/8: kyky_dress")
    kyky = Image.open(os.path.join(CHARS, "kyky_hug.png")).convert("RGBA")
    res = kyky.copy()
    d = ImageDraw.Draw(res)
    d.ellipse([82, 178, 104, 196], fill=(255, 255, 255, 255), outline=DARK_LINE, width=2)
    d.ellipse([102, 178, 124, 196], fill=(255, 255, 255, 255), outline=DARK_LINE, width=2)
    
    cardigan_pts = [(70, 195), (135, 195), (155, 230), (160, 355), (46, 355), (50, 230)]
    d.polygon(cardigan_pts, fill=(248, 230, 150, 255), outline=DARK_LINE)
    d.rectangle([46, 345, 160, 358], fill=(235, 215, 130, 255), outline=DARK_LINE, width=2)
    d.polygon([(96, 195), (110, 195), (108, 345), (98, 345)], fill=(250, 246, 234, 255))
    for cy in [220, 250, 280, 310, 335]:
        d.ellipse([101, cy-2, 105, cy+2], fill=(255, 255, 255, 255), outline=DARK_LINE)
        
    skirt_pts = [(46, 355), (160, 355), (175, 430), (32, 430)]
    d.polygon(skirt_pts, fill=(250, 246, 234, 255), outline=DARK_LINE)
    for sx in [68, 105, 142]:
        d.line([(sx, 355), (sx + (sx-105)//3, 430)], fill=(225, 218, 202, 255), width=2)
    d.line([(32, 430), (175, 430)], fill=DARK_LINE, width=2)
    
    d.line([(78, 190), (145, 340)], fill=(160, 115, 75, 255), width=4)
    d.line([(78, 190), (145, 340)], fill=DARK_LINE, width=1)
    
    cat_box = [126, 325, 168, 365]
    d.rounded_rectangle(cat_box, radius=8, fill=(250, 242, 230, 255), outline=DARK_LINE, width=2)
    d.polygon([(132, 325), (137, 315), (144, 325)], fill=(250, 242, 230, 255), outline=DARK_LINE)
    d.polygon([(150, 325), (157, 315), (162, 325)], fill=(250, 242, 230, 255), outline=DARK_LINE)
    d.polygon([(145, 342), (149, 342), (147, 345)], fill=(230, 140, 150, 255))
    d.line([(135, 343), (143, 344)], fill=DARK_LINE, width=1)
    d.line([(151, 344), (159, 343)], fill=DARK_LINE, width=1)
    
    res_arr = np.array(res)
    k_arr = np.array(kyky)
    is_hand_l = (k_arr[:,:,0] > 190) & (k_arr[:,:,1] > 140) & (k_arr[:,:,2] > 120) & (np.arange(kyky.height)[:, None] >= 240) & (np.arange(kyky.height)[:, None] <= 300) & (np.arange(kyky.width)[None, :] <= 52)
    is_hand_r = (k_arr[:,:,0] > 190) & (k_arr[:,:,1] > 140) & (k_arr[:,:,2] > 120) & (np.arange(kyky.height)[:, None] >= 235) & (np.arange(kyky.height)[:, None] <= 290) & (np.arange(kyky.width)[None, :] >= 105)
    is_hand = is_hand_l | is_hand_r
    res_arr[is_hand] = k_arr[is_hand]
    return clean_alpha_border(Image.fromarray(res_arr))

def build_hai_flowers():
    print("5/8: hai_flowers")
    hai = Image.open(os.path.join(CHARS, "hai_front.png")).convert("RGBA")
    arr = np.array(hai)
    cx = 106
    for y in range(175, 215):
        for dx in range(1, 45):
            sx = cx - dx
            tx = cx + dx
            if sx >= 0 and tx < arr.shape[1]:
                if arr[y, sx, 3] > 0:
                    arr[y, tx] = arr[y, sx]
    for y in range(300, 450):
        for x in range(0, 75):
            if arr[y, x, 3] > 0:
                arr[y, x] = [45, 45, 45, 255]
                
    is_waving = (np.arange(hai.height)[:, None] >= 170) & (np.arange(hai.height)[:, None] <= 245) & (np.arange(hai.width)[None, :] >= 180)
    arr[is_waving] = 0
    res = Image.fromarray(arr)
    d = ImageDraw.Draw(res)
    d.polygon([(150, 220), (185, 235), (175, 335), (145, 330)], fill=(245, 245, 242, 255), outline=DARK_LINE, width=2)
    
    cone_pts = [(115, 385), (75, 315), (155, 315)]
    d.polygon(cone_pts, fill=(210, 168, 125, 255), outline=DARK_LINE)
    d.ellipse([105, 335, 125, 348], fill=(160, 205, 235, 255), outline=DARK_LINE, width=2)
    d.polygon([(115, 341), (95, 332), (98, 348)], fill=(160, 205, 235, 255), outline=DARK_LINE)
    d.polygon([(115, 341), (135, 332), (132, 348)], fill=(160, 205, 235, 255), outline=DARK_LINE)
    d.line([(112, 348), (105, 368)], fill=(160, 205, 235, 255), width=3)
    d.line([(118, 348), (125, 368)], fill=(160, 205, 235, 255), width=3)
    
    d.polygon([(115, 315), (70, 275), (95, 255), (115, 315)], fill=(75, 125, 65, 255), outline=DARK_LINE)
    d.polygon([(115, 315), (160, 275), (135, 255), (115, 315)], fill=(85, 135, 75, 255), outline=DARK_LINE)
    d.polygon([(115, 315), (115, 245), (125, 245), (115, 315)], fill=(95, 145, 85, 255), outline=DARK_LINE)
    
    flowers = [(85, 270), (95, 260), (108, 252), (122, 252), (135, 260), (145, 270),
               (90, 285), (102, 275), (115, 268), (128, 275), (140, 285)]
    for fx, fy in flowers:
        d.line([(fx, fy-5), (fx, fy)], fill=(65, 115, 55, 255), width=2)
        d.ellipse([fx-5, fy, fx+5, fy+8], fill=(255, 255, 255, 255), outline=DARK_LINE, width=1)
        d.polygon([(fx-5, fy+6), (fx-3, fy+9), (fx, fy+7), (fx+3, fy+9), (fx+5, fy+6)], fill=(255, 255, 255, 255))
        
    d.ellipse([68, 312, 92, 336], fill=(245, 205, 185, 255), outline=DARK_LINE, width=2)
    d.ellipse([138, 312, 162, 336], fill=(245, 205, 185, 255), outline=DARK_LINE, width=2)
    return clean_alpha_border(res)

def build_prof_front():
    print("6/8: prof_front")
    hai = Image.open(os.path.join(CHARS, "hai_front.png")).convert("RGBA")
    arr = np.array(hai)
    cx = 106
    for y in range(175, 215):
        for dx in range(1, 45):
            sx = cx - dx
            tx = cx + dx
            if sx >= 0 and tx < arr.shape[1]:
                if arr[y, sx, 3] > 0:
                    arr[y, tx] = arr[y, sx]
    for y in range(300, 450):
        for x in range(0, 75):
            if arr[y, x, 3] > 0:
                arr[y, x] = [45, 45, 45, 255]
                
    r, g, b, a = arr[:,:,0], arr[:,:,1], arr[:,:,2], arr[:,:,3]
    is_hair = (a > 200) & (r < 70) & (g < 70) & (b < 70) & (np.arange(hai.height)[:, None] <= 110)
    lum = 0.299*r + 0.587*g + 0.114*b
    is_hair_body = is_hair & (lum > 22)
    arr[is_hair_body, 0] = np.clip(r[is_hair_body].astype(int) + 75, 0, 165)
    arr[is_hair_body, 1] = np.clip(g[is_hair_body].astype(int) + 75, 0, 165)
    arr[is_hair_body, 2] = np.clip(b[is_hair_body].astype(int) + 80, 0, 170)
    
    for y in range(178, 235):
        w = 4 if y < 210 else 6
        arr[y, 110-w:110+w, :3] = [135, 25, 40]
        
    is_waving = (np.arange(hai.height)[:, None] >= 170) & (np.arange(hai.height)[:, None] <= 245) & (np.arange(hai.width)[None, :] >= 180)
    arr[is_waving] = 0
    res = Image.fromarray(arr)
    d = ImageDraw.Draw(res)
    d.polygon([(150, 220), (185, 235), (175, 335), (145, 330)], fill=(245, 245, 242, 255), outline=DARK_LINE, width=2)
    d.ellipse([148, 315, 172, 345], fill=(245, 205, 185, 255), outline=DARK_LINE, width=2)
    
    d.ellipse([70, 102, 98, 128], outline=(205, 165, 55, 255), width=2)
    d.ellipse([120, 100, 148, 126], outline=(205, 165, 55, 255), width=2)
    d.line([(98, 114), (120, 112)], fill=(205, 165, 55, 255), width=2)
    
    d.arc([88, 130, 124, 144], start=180, end=360, fill=(125, 120, 115, 255), width=3)
    d.ellipse([102, 148, 114, 158], fill=(125, 120, 115, 255), outline=DARK_LINE, width=1)
    return clean_alpha_border(res)

def build_teacher_front():
    print("7/8: teacher_front")
    hai = Image.open(os.path.join(CHARS, "hai_front.png")).convert("RGBA")
    arr = np.array(hai)
    
    r, g, b, a = arr[:,:,0], arr[:,:,1], arr[:,:,2], arr[:,:,3]
    is_vest = (a > 200) & (r > 160) & (g > 150) & (b > 120) & (np.arange(hai.height)[:, None] >= 170) & (np.arange(hai.height)[:, None] <= 370)
    arr[is_vest, :3] = [164, 196, 232]
    
    cx = 106
    for y in range(175, 215):
        for dx in range(1, 45):
            sx = cx - dx
            tx = cx + dx
            if sx >= 0 and tx < arr.shape[1]:
                if arr[y, sx, 3] > 0:
                    arr[y, tx] = [164, 196, 232, 255]
    for y in range(300, 450):
        for x in range(0, 75):
            if arr[y, x, 3] > 0:
                arr[y, x] = [45, 45, 45, 255]
                
    is_waving = (np.arange(hai.height)[:, None] >= 170) & (np.arange(hai.height)[:, None] <= 245) & (np.arange(hai.width)[None, :] >= 180)
    arr[is_waving] = 0
    
    is_temple = (np.arange(hai.height)[:, None] >= 65) & (np.arange(hai.height)[:, None] <= 100) & (((np.arange(hai.width)[None, :] >= 45) & (np.arange(hai.width)[None, :] <= 58)) | ((np.arange(hai.width)[None, :] >= 155) & (np.arange(hai.width)[None, :] <= 168)))
    arr[is_temple & (arr[:,:,3] > 200), :3] = [140, 140, 145]
    
    res = Image.fromarray(arr)
    d = ImageDraw.Draw(res)
    d.polygon([(150, 220), (185, 235), (175, 335), (145, 330)], fill=(164, 196, 232, 255), outline=DARK_LINE, width=2)
    d.ellipse([148, 315, 172, 345], fill=(245, 205, 185, 255), outline=DARK_LINE, width=2)
    
    d.rounded_rectangle([42, 275, 80, 365], radius=4, fill=(28, 48, 85, 255), outline=DARK_LINE, width=2)
    d.rectangle([42, 275, 50, 365], fill=(215, 180, 85, 255))
    
    d.rectangle([70, 102, 98, 126], outline=DARK_LINE, width=2)
    d.rectangle([120, 100, 148, 124], outline=DARK_LINE, width=2)
    d.line([(98, 114), (120, 112)], fill=DARK_LINE, width=2)
    return clean_alpha_border(res)

def build_mom_front():
    print("8/8: mom_front")
    tram = Image.open(os.path.join(CHARS, "tram_front.png")).convert("RGBA")
    head = tram.crop((10, 0, 210, 148))
    h_arr = np.array(head)
    
    r, g, b, a = h_arr[:,:,0], h_arr[:,:,1], h_arr[:,:,2], h_arr[:,:,3]
    is_pin = (a > 200) & (r > 150) & (g > 140) & (b > 150) & (np.arange(head.height)[:, None] >= 45) & (np.arange(head.height)[:, None] <= 75) & (np.arange(head.width)[None, :] >= 130) & (np.arange(head.width)[None, :] <= 160)
    h_arr[is_pin, :3] = [54, 36, 30]
    
    head_clean = Image.fromarray(h_arr)
    d_h = ImageDraw.Draw(head_clean)
    d_h.ellipse([42, 112, 50, 120], fill=(255, 255, 255, 255), outline=DARK_LINE, width=1)
    d_h.ellipse([142, 112, 150, 120], fill=(255, 255, 255, 255), outline=DARK_LINE, width=1)
    d_h.line([(88, 104), (93, 101)], fill=DARK_LINE, width=2)
    d_h.line([(138, 104), (143, 101)], fill=DARK_LINE, width=2)
    
    out = Image.new("RGBA", (210, 600), (0, 0, 0, 0))
    d = ImageDraw.Draw(out)
    
    d.ellipse([25, 70, 185, 230], fill=(54, 36, 30, 255), outline=DARK_LINE, width=3)
    d.ellipse([18, 175, 65, 240], fill=(54, 36, 30, 255), outline=DARK_LINE, width=2)
    d.ellipse([145, 175, 192, 240], fill=(54, 36, 30, 255), outline=DARK_LINE, width=2)
    
    d.polygon([(62, 360), (148, 360), (158, 560), (118, 560), (105, 410), (92, 560), (52, 560)], fill=(36, 34, 33, 255), outline=DARK_LINE, width=2)
    d.polygon([(50, 560), (90, 560), (86, 595), (46, 595)], fill=(22, 20, 20, 255), outline=DARK_LINE, width=2)
    d.polygon([(120, 560), (160, 560), (164, 595), (124, 595)], fill=(22, 20, 20, 255), outline=DARK_LINE, width=2)
    
    d.rectangle([98, 140, 112, 195], fill=(245, 205, 185, 255), outline=DARK_LINE, width=2)
    
    blouse_pts = [(88, 190), (122, 190), (160, 230), (165, 365), (45, 365), (50, 230)]
    d.polygon(blouse_pts, fill=(30, 107, 82, 255), outline=DARK_LINE, width=2)
    d.polygon([(45, 365), (165, 365), (162, 345), (48, 345)], fill=(20, 77, 58, 255))
    d.polygon([(96, 190), (114, 190), (105, 218)], fill=(245, 205, 185, 255), outline=DARK_LINE, width=2)
    d.ellipse([100, 215, 110, 225], fill=(215, 180, 85, 255), outline=DARK_LINE, width=1)
    d.ellipse([103, 218, 107, 222], fill=(255, 255, 255, 255))
    
    d.ellipse([84, 318, 126, 346], fill=(245, 205, 185, 255), outline=DARK_LINE, width=2)
    d.line([(96, 332), (114, 332)], fill=DARK_LINE, width=1)
    
    d.rounded_rectangle([42, 315, 70, 355], radius=4, fill=(26, 24, 23, 255), outline=DARK_LINE, width=2)
    d.rectangle([52, 315, 60, 355], fill=(215, 180, 85, 255))
    
    out.alpha_composite(head_clean, (5, 5))
    return clean_alpha_border(out)

def generate_expressions_for(base_name, spec_base, expr_list, target_chars_dir):
    print(f"Generating expressions for {base_name}: {expr_list}")
    spec = FACES[spec_base]
    for expr in expr_list:
        face = Face(base_name, spec)
        im = face.render(expr)
        out_path = os.path.join(target_chars_dir, f"{base_name}_{expr}.png")
        im.save(out_path, optimize=True)
        print(f"  -> {out_path}")

def main():
    target_dirs = [CHARS]
    agy_chars = "C:/devgame2D-agy/game/assets/art/chars"
    if os.path.exists(agy_chars) and agy_chars not in target_dirs:
        target_dirs.append(agy_chars)
        
    print(f"Targets: {target_dirs}")
    
    builders = {
        "duc_apron": build_duc_apron,
        "kyky_apron": build_kyky_apron,
        "duc_shirt": build_duc_shirt,
        "kyky_dress": build_kyky_dress,
        "hai_flowers": build_hai_flowers,
        "prof_front": build_prof_front,
        "teacher_front": build_teacher_front,
        "mom_front": build_mom_front,
    }
    
    # 1. Build & save base sprites
    for name, fn in builders.items():
        base_im = fn()
        for tdir in target_dirs:
            p = os.path.join(tdir, f"{name}.png")
            base_im.save(p)
            print(f"Saved base {p} ({base_im.size})")
            
    # 2. Đăng ký FACES cho base mới
    FACES["duc_apron"] = FACES["duc_front"]
    FACES["duc_shirt"] = FACES["duc_front"]
    FACES["kyky_apron"] = FACES["kyky_hug"]
    FACES["kyky_dress"] = FACES["kyky_hug"]
    FACES["hai_flowers"] = FACES["hai_front"]
    FACES["prof_front"] = FACES["hai_front"]
    FACES["teacher_front"] = FACES["hai_front"]
    FACES["mom_front"] = FACES["tram_front"]
    
    # 3. Danh sách biểu cảm bắt buộc từ yeucau_sua_sprite_v2.md
    EXPR_PLAN = {
        "duc_apron": ("duc_front", ["smirk", "happy", "shy", "worried"]),
        "kyky_apron": ("kyky_hug", ["happy", "worried", "shy", "sparkle"]),
        "duc_shirt": ("duc_front", ["think", "shy", "awkward", "soft"]),
        "kyky_dress": ("kyky_hug", ["happy", "shy", "worried", "sparkle"]),
        "hai_flowers": ("hai_front", ["smile", "stunned", "shy"]),
        "mom_front": ("tram_front", ["smile", "serious", "glare"]),
        "teacher_front": ("hai_front", ["smile", "think"]),
        "prof_front": ("hai_front", ["smile", "think"]),
    }
    
    for base_name, (spec_base, expr_list) in EXPR_PLAN.items():
        for tdir in target_dirs:
            generate_expressions_for(base_name, spec_base, expr_list, tdir)
            
    # 4. Tạo bảng so sánh review_v2.png
    print("=== TẠO BẢNG SO SÁNH REVIEW_V2.PNG ===")
    refs = {
        "duc": Image.open(os.path.join(CHARS, "duc_stand.png")).convert("RGBA"),
        "kyky": Image.open(os.path.join(CHARS, "kyky_hug.png")).convert("RGBA"),
        "hai": Image.open(os.path.join(CHARS, "hai_front.png")).convert("RGBA"),
    }
    
    pairs = [
        ("Gốc Đức", refs["duc"], "duc_apron", Image.open(os.path.join(CHARS, "duc_apron.png"))),
        ("Gốc KyKy", refs["kyky"], "kyky_apron", Image.open(os.path.join(CHARS, "kyky_apron.png"))),
        ("Gốc Đức", refs["duc"], "duc_shirt", Image.open(os.path.join(CHARS, "duc_shirt.png"))),
        ("Gốc KyKy", refs["kyky"], "kyky_dress", Image.open(os.path.join(CHARS, "kyky_dress.png"))),
        ("Gốc Hải", refs["hai"], "hai_flowers", Image.open(os.path.join(CHARS, "hai_flowers.png"))),
        ("Mẹ KyKy", Image.open(os.path.join(CHARS, "mom_front.png")), "Thầy Dean", Image.open(os.path.join(CHARS, "teacher_front.png"))),
        ("GS Pháp", Image.open(os.path.join(CHARS, "prof_front.png")), "", None),
    ]
    
    total_w = sum(p[1].width + (p[3].width if p[3] else 0) + 15 for p in pairs) + 20
    sheet = Image.new("RGBA", (total_w, 640), (28, 28, 32, 255))
    x = 10
    d_sheet = ImageDraw.Draw(sheet)
    for l1, im1, l2, im2 in pairs:
        sheet.alpha_composite(im1, (x, 10))
        d_sheet.text((x + 10, 620), l1, fill=(200, 200, 200, 255))
        x += im1.width + 8
        if im2:
            sheet.alpha_composite(im2, (x, 10))
            d_sheet.text((x + 10, 620), l2, fill=(245, 210, 110, 255))
            x += im2.width + 16
            
    sheet.save(os.path.join(SHOTS, "review_v2.png"))
    # Copy to C:/devgame2D-agy/build/shots if exists
    agy_shots = "C:/devgame2D-agy/build/shots"
    if os.path.exists(agy_shots):
        sheet.save(os.path.join(agy_shots, "review_v2.png"))
        
    print("HOÀN THÀNH TOÀN BỘ SPRITE VÀ BIỂU CẢM CHIBI V2!")

if __name__ == "__main__":
    main()
