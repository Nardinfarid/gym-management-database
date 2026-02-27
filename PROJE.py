import os
import cv2
import numpy as np
import pandas as pd
from tqdm import tqdm

from skimage.feature import graycomatrix, graycoprops, local_binary_pattern
from skimage.filters import gabor
from skimage import img_as_ubyte
import pywt
import arff

# ===================== PATHS =====================
BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
DATASET_DIR = os.path.join(BASE_DIR, 'data_prepared')

FEATURE_DIR = os.path.join(BASE_DIR, 'features')
ARFF_DIR = os.path.join(BASE_DIR, 'arff')

# ARFF subfolders
ARFF_ANGLES_DIR = os.path.join(ARFF_DIR, 'angles')
ARFF_DISTS_DIR = os.path.join(ARFF_DIR, 'dists')
ARFF_PROPS_DIR = os.path.join(ARFF_DIR, 'props')
ARFF_PROP_ANGLE_DIR = os.path.join(ARFF_DIR, 'prop_angle')
ARFF_PROP_DIST_DIR = os.path.join(ARFF_DIR, 'prop_dist')
ARFF_SETS_DIR = os.path.join(ARFF_DIR, 'sets')

# CSV subfolders (new)
CSV_SETS_DIR = os.path.join(FEATURE_DIR, 'sets_csv')
CSV_ANGLES_DIR = os.path.join(FEATURE_DIR, 'angles_csv')
CSV_DISTS_DIR = os.path.join(FEATURE_DIR, 'dists_csv')
CSV_PROPS_DIR = os.path.join(FEATURE_DIR, 'props_csv')
CSV_PROP_ANGLE_DIR = os.path.join(FEATURE_DIR, 'prop_angle_csv')
CSV_PROP_DIST_DIR = os.path.join(FEATURE_DIR, 'prop_dist_csv')

for d in [
    FEATURE_DIR, ARFF_DIR,
    ARFF_ANGLES_DIR, ARFF_DISTS_DIR, ARFF_PROPS_DIR, ARFF_PROP_ANGLE_DIR, ARFF_PROP_DIST_DIR, ARFF_SETS_DIR,
    CSV_SETS_DIR, CSV_ANGLES_DIR, CSV_DISTS_DIR, CSV_PROPS_DIR, CSV_PROP_ANGLE_DIR, CSV_PROP_DIST_DIR
]:
    os.makedirs(d, exist_ok=True)

# ===================== PARAMETERS =====================
IMAGE_SIZE = (256, 256)

GLCM_ANGLES = [0, np.pi/4, np.pi/2, 3*np.pi/4]   # PDF required
ANGLE_NAMES = ['0', '45', '90', '135']

GLCM_DISTS  = [1, 2, 3, 4]                        # richer
GLCM_BASE_PROPS = ['contrast','dissimilarity','homogeneity','energy','correlation','ASM']  # PDF base 6
GLCM_EXTRA_KEYS = ['entropy','max_probability','mean_i','mean_j','var_i','var_j']          # derived extras

LBP_RADIUS = 2
LBP_POINTS = 8 * LBP_RADIUS

# Gabor bank
GABOR_THETAS = [0, np.pi/4, np.pi/2, 3*np.pi/4]
GABOR_FREQS  = [0.1, 0.2]

# ===================== UTIL =====================
def safe_entropy(p):
    p = p[p > 0]
    return float(-(p * np.log2(p)).sum()) if p.size else 0.0

def skew_kurt(x):
    x = x.astype(np.float64).ravel()
    m = x.mean()
    s = x.std() + 1e-12
    z = (x - m) / s
    skew = float((z**3).mean())
    kurt = float((z**4).mean() - 3.0)
    return skew, kurt

# ===================== FEATURE EXTRACTORS =====================
def extract_global(gray_u8):
    x = gray_u8.astype(np.float64)
    feat = {}
    feat['global_mean'] = float(x.mean())
    feat['global_std']  = float(x.std())
    feat['global_min']  = float(x.min())
    feat['global_max']  = float(x.max())
    sk, ku = skew_kurt(x)
    feat['global_skew'] = sk
    feat['global_kurt'] = ku

    hist = np.bincount(gray_u8.ravel(), minlength=256).astype(np.float64)
    p = hist / (hist.sum() + 1e-12)
    feat['global_entropy'] = safe_entropy(p)
    feat['global_uniformity'] = float((p**2).sum())

    edges = cv2.Canny(gray_u8, 50, 150)
    feat['edge_density'] = float((edges > 0).mean())

    lap = cv2.Laplacian(gray_u8, cv2.CV_64F)
    feat['laplacian_var'] = float(lap.var())
    return feat

def extract_lbp_summary(gray_u8):
    lbp = local_binary_pattern(gray_u8, LBP_POINTS, LBP_RADIUS, method='uniform')
    hist, _ = np.histogram(lbp.ravel(),
                           bins=np.arange(0, LBP_POINTS + 3),
                           range=(0, LBP_POINTS + 2),
                           density=True)
    feat = {}
    feat['lbp_entropy'] = safe_entropy(hist)
    feat['lbp_peak'] = float(hist.max()) if len(hist) else 0.0
    feat['lbp_var'] = float(hist.var()) if len(hist) else 0.0
    non_uniform = hist[-1] if len(hist) else 0.0
    feat['lbp_uniform_ratio'] = float(1.0 - non_uniform)
    return feat

def extract_hog_summary(gray_u8):
    gx = cv2.Sobel(gray_u8, cv2.CV_64F, 1, 0, ksize=3)
    gy = cv2.Sobel(gray_u8, cv2.CV_64F, 0, 1, ksize=3)
    mag = np.sqrt(gx*gx + gy*gy)
    feat = {}
    feat['hog_mean_grad'] = float(mag.mean())
    feat['hog_std_grad']  = float(mag.std())
    feat['hog_max_grad']  = float(mag.max())
    feat['hog_energy_grad'] = float((mag**2).mean())
    return feat

def extract_wavelet(gray_u8):
    x = gray_u8.astype(np.float64)
    cA, (cH, cV, cD) = pywt.dwt2(x, 'haar')
    bands = {'LL': cA, 'LH': cH, 'HL': cV, 'HH': cD}

    feat = {}
    for name, b in bands.items():
        b2 = b.ravel().astype(np.float64)
        feat[f'wav_{name}_mean'] = float(b2.mean())
        feat[f'wav_{name}_std']  = float(b2.std())
        feat[f'wav_{name}_energy'] = float((b2*b2).mean())

        bb = b2 - b2.min()
        if bb.max() > 0:
            q = np.clip((bb / bb.max() * 255).astype(np.uint8), 0, 255)
            hist = np.bincount(q, minlength=256).astype(np.float64)
            p = hist / (hist.sum() + 1e-12)
            feat[f'wav_{name}_entropy'] = safe_entropy(p)
        else:
            feat[f'wav_{name}_entropy'] = 0.0
    return feat

def extract_gabor(gray_u8):
    x = gray_u8.astype(np.float64) / 255.0
    feat = {}
    idx = 0
    for f in GABOR_FREQS:
        for th in GABOR_THETAS:
            real, imag = gabor(x, frequency=f, theta=th)
            mag = np.sqrt(real*real + imag*imag)
            feat[f'gabor_{idx}_mean'] = float(mag.mean())
            feat[f'gabor_{idx}_std']  = float(mag.std())
            idx += 1
    return feat

def glcm_extra_from_P(P):
    feat = {}
    p = P[P > 0]
    feat['entropy'] = float(-(p * np.log2(p)).sum()) if p.size else 0.0
    feat['max_probability'] = float(P.max())

    i = np.arange(P.shape[0], dtype=np.float64)
    j = np.arange(P.shape[1], dtype=np.float64)
    pi = P.sum(axis=1)
    pj = P.sum(axis=0)
    mi = float((i * pi).sum())
    mj = float((j * pj).sum())
    vi = float(((i - mi)**2 * pi).sum())
    vj = float(((j - mj)**2 * pj).sum())

    feat['mean_i'] = mi
    feat['mean_j'] = mj
    feat['var_i'] = vi
    feat['var_j'] = vj
    return feat

def extract_glcm_max(gray_u8):
    feat = {}
    dist_angle_means = {}  # prop -> list of dist-level angle_means

    for d in GLCM_DISTS:
        G = graycomatrix(gray_u8, distances=[d], angles=GLCM_ANGLES, levels=256,
                         symmetric=True, normed=True)

        # base props
        for prop in GLCM_BASE_PROPS:
            vals = graycoprops(G, prop)[0, :]
            for a_idx, a_name in enumerate(ANGLE_NAMES):
                feat[f'glcm_d{d}_{prop}_a{a_name}'] = float(vals[a_idx])
            feat[f'glcm_d{d}_{prop}_ang_mean'] = float(vals.mean())
            feat[f'glcm_d{d}_{prop}_ang_std']  = float(vals.std())
            dist_angle_means.setdefault(prop, []).append(float(vals.mean()))

        # extra props per angle
        for a_idx, a_name in enumerate(ANGLE_NAMES):
            P = G[:, :, 0, a_idx].astype(np.float64)
            extra = glcm_extra_from_P(P)
            for k, v in extra.items():
                feat[f'glcm_d{d}_{k}_a{a_name}'] = float(v)

        # summarize extras across angles
        for k in GLCM_EXTRA_KEYS:
            arr = np.array([feat[f'glcm_d{d}_{k}_a{a}'] for a in ANGLE_NAMES], dtype=np.float64)
            feat[f'glcm_d{d}_{k}_ang_mean'] = float(arr.mean())
            feat[f'glcm_d{d}_{k}_ang_std']  = float(arr.std())
            dist_angle_means.setdefault(k, []).append(float(arr.mean()))

    # summarize across distances using dist-level angle_means
    for k, vals in dist_angle_means.items():
        arr = np.array(vals, dtype=np.float64)
        feat[f'glcm_{k}_dist_mean'] = float(arr.mean())
        feat[f'glcm_{k}_dist_std']  = float(arr.std())

    return feat

# ===================== SAVE HELPERS =====================
def save_csv(df, filename):
    df.to_csv(filename, index=False)

def save_arff(df, filename, class_names):
    attributes = []
    for col in df.columns:
        if col == 'class':
            attributes.append(('class', class_names))
        else:
            attributes.append((col, 'REAL'))
    arff_data = {
        'description': 'Malimg Malware Classification',
        'relation': 'malimg',
        'attributes': attributes,
        'data': df.values.tolist()
    }
    with open(filename, 'w') as f:
     arff.dump(arff_data, f)

def save_both(df, arff_path, csv_path, class_names):
    save_arff(df, arff_path, class_names)
    save_csv(df, csv_path)

# ===================== SUBSET GENERATORS =====================
def generate_set_files(df, class_names):
    glcm_cols = [c for c in df.columns if c.startswith('glcm_')]
    wav_cols  = [c for c in df.columns if c.startswith('wav_')]
    gab_cols  = [c for c in df.columns if c.startswith('gabor_')]
    glob_cols = [c for c in df.columns if c.startswith('global_') or c in ['edge_density','laplacian_var']]
    lbp_cols  = [c for c in df.columns if c.startswith('lbp_')]
    hog_cols  = [c for c in df.columns if c.startswith('hog_')]

    # Full
    save_both(
        df,
        os.path.join(ARFF_SETS_DIR, 'MAX_all_features.arff'),
        os.path.join(CSV_SETS_DIR, 'MAX_all_features.csv'),
        class_names
    )

    # Groups
    save_both(df[glcm_cols + ['class']], os.path.join(ARFF_SETS_DIR, 'GLCM_all.arff'),
              os.path.join(CSV_SETS_DIR, 'GLCM_all.csv'), class_names)

    save_both(df[wav_cols + ['class']], os.path.join(ARFF_SETS_DIR, 'Wavelet_only.arff'),
              os.path.join(CSV_SETS_DIR, 'Wavelet_only.csv'), class_names)

    save_both(df[gab_cols + ['class']], os.path.join(ARFF_SETS_DIR, 'Gabor_only.arff'),
              os.path.join(CSV_SETS_DIR, 'Gabor_only.csv'), class_names)

    save_both(df[glob_cols + ['class']], os.path.join(ARFF_SETS_DIR, 'Global_only.arff'),
              os.path.join(CSV_SETS_DIR, 'Global_only.csv'), class_names)

    save_both(df[lbp_cols + ['class']], os.path.join(ARFF_SETS_DIR, 'LBP_summary_only.arff'),
              os.path.join(CSV_SETS_DIR, 'LBP_summary_only.csv'), class_names)

    save_both(df[hog_cols + ['class']], os.path.join(ARFF_SETS_DIR, 'HOG_summary_only.arff'),
              os.path.join(CSV_SETS_DIR, 'HOG_summary_only.csv'), class_names)

    # Fusion sets
    save_both(df[glcm_cols + wav_cols + ['class']], os.path.join(ARFF_SETS_DIR, 'GLCM_Wavelet.arff'),
              os.path.join(CSV_SETS_DIR, 'GLCM_Wavelet.csv'), class_names)

    save_both(df[glcm_cols + gab_cols + ['class']], os.path.join(ARFF_SETS_DIR, 'GLCM_Gabor.arff'),
              os.path.join(CSV_SETS_DIR, 'GLCM_Gabor.csv'), class_names)

    save_both(df[glcm_cols + lbp_cols + hog_cols + ['class']], os.path.join(ARFF_SETS_DIR, 'GLCM_LBP_HOGsummary.arff'),
              os.path.join(CSV_SETS_DIR, 'GLCM_LBP_HOGsummary.csv'), class_names)

    save_both(df[glcm_cols + wav_cols + gab_cols + lbp_cols + hog_cols + glob_cols + ['class']],
              os.path.join(ARFF_SETS_DIR, 'GLCM_Wav_Gab_LBP_HOG_Global.arff'),
              os.path.join(CSV_SETS_DIR, 'GLCM_Wav_Gab_LBP_HOG_Global.csv'),
              class_names)

    print("✅ SET files created (ARFF + CSV):", ARFF_SETS_DIR, "and", CSV_SETS_DIR)

def generate_many_files(df, class_names):
    ALL_PROPS = GLCM_BASE_PROPS + GLCM_EXTRA_KEYS

    # 1) Per-angle for each distance (base 6)
    for d in GLCM_DISTS:
        for a in ANGLE_NAMES:
            cols = [f'glcm_d{d}_{p}_a{a}' for p in GLCM_BASE_PROPS if f'glcm_d{d}_{p}_a{a}' in df.columns]
            if cols:
                save_both(
                    df[cols + ['class']],
                    os.path.join(ARFF_ANGLES_DIR, f'GLCM_d{d}_angle_{a}_base6.arff'),
                    os.path.join(CSV_ANGLES_DIR,  f'GLCM_d{d}_angle_{a}_base6.csv'),
                    class_names
                )

    # 2) Per-dist base6 angle mean+std
    for d in GLCM_DISTS:
        cols = []
        for p in GLCM_BASE_PROPS:
            c1 = f'glcm_d{d}_{p}_ang_mean'
            c2 = f'glcm_d{d}_{p}_ang_std'
            if c1 in df.columns: cols.append(c1)
            if c2 in df.columns: cols.append(c2)
        if cols:
            save_both(
                df[cols + ['class']],
                os.path.join(ARFF_DISTS_DIR, f'GLCM_d{d}_base6_ang_mean_std.arff'),
                os.path.join(CSV_DISTS_DIR,  f'GLCM_d{d}_base6_ang_mean_std.csv'),
                class_names
            )

    # 3) Per-prop single column (dist_mean + dist_std)
    for p in ALL_PROPS:
        c_mean = f'glcm_{p}_dist_mean'
        c_std  = f'glcm_{p}_dist_std'
        if c_mean in df.columns:
            save_both(
                df[[c_mean, 'class']],
                os.path.join(ARFF_PROPS_DIR, f'PROP_{p}_dist_mean.arff'),
                os.path.join(CSV_PROPS_DIR,  f'PROP_{p}_dist_mean.csv'),
                class_names
            )
        if c_std in df.columns:
            save_both(
                df[[c_std, 'class']],
                os.path.join(ARFF_PROPS_DIR, f'PROP_{p}_dist_std.arff'),
                os.path.join(CSV_PROPS_DIR,  f'PROP_{p}_dist_std.csv'),
                class_names
            )

    # 4) Per-prop + angle single column (d=1, raw)
    for p in ALL_PROPS:
        for a in ANGLE_NAMES:
            col = f'glcm_d1_{p}_a{a}'
            if col in df.columns:
                save_both(
                    df[[col, 'class']],
                    os.path.join(ARFF_PROP_ANGLE_DIR, f'PROP_{p}_angle_{a}_d1.arff'),
                    os.path.join(CSV_PROP_ANGLE_DIR,  f'PROP_{p}_angle_{a}_d1.csv'),
                    class_names
                )

    # 5) Per-prop + dist single column (angle-mean per dist)
    for p in ALL_PROPS:
        for d in GLCM_DISTS:
            col = f'glcm_d{d}_{p}_ang_mean'
            if col in df.columns:
                save_both(
                    df[[col, 'class']],
                    os.path.join(ARFF_PROP_DIST_DIR, f'PROP_{p}_d{d}_ang_mean.arff'),
                    os.path.join(CSV_PROP_DIST_DIR,  f'PROP_{p}_d{d}_ang_mean.csv'),
                    class_names
                )

    print("✅ MANY files created (ARFF + CSV):")
    print(" -", ARFF_ANGLES_DIR, "and", CSV_ANGLES_DIR)
    print(" -", ARFF_DISTS_DIR, "and", CSV_DISTS_DIR)
    print(" -", ARFF_PROPS_DIR, "and", CSV_PROPS_DIR)
    print(" -", ARFF_PROP_ANGLE_DIR, "and", CSV_PROP_ANGLE_DIR)
    print(" -", ARFF_PROP_DIST_DIR, "and", CSV_PROP_DIST_DIR)

# ===================== MAIN =====================
def main():
    if not os.path.isdir(DATASET_DIR):
        raise RuntimeError(f"Dataset folder not found: {DATASET_DIR}")

    class_names = sorted([d for d in os.listdir(DATASET_DIR) if os.path.isdir(os.path.join(DATASET_DIR, d))])
    if not class_names:
        raise RuntimeError(f"No class folders found in {DATASET_DIR}. Check your data_prepared structure.")

    rows = []
    for cls in class_names:
        cls_path = os.path.join(DATASET_DIR, cls)
        imgs = [f for f in os.listdir(cls_path) if not f.startswith('.')]
        for img_name in tqdm(imgs, desc=f"Extracting {cls}"):
            p = os.path.join(cls_path, img_name)
            gray = cv2.imread(p, cv2.IMREAD_GRAYSCALE)
            if gray is None:
                continue
            gray = cv2.resize(gray, IMAGE_SIZE)
            gray = img_as_ubyte(gray)

            feat = {}
            feat.update(extract_global(gray))
            feat.update(extract_glcm_max(gray))
            feat.update(extract_wavelet(gray))
            feat.update(extract_gabor(gray))
            feat.update(extract_lbp_summary(gray))
            feat.update(extract_hog_summary(gray))

            feat['class'] = cls
            rows.append(feat)

    df = pd.DataFrame(rows)
    cols = [c for c in df.columns if c != 'class']
    df = df[sorted(cols) + ['class']]

    # Master CSV (reference)
    master_csv = os.path.join(FEATURE_DIR, 'master_max_features.csv')
    df.to_csv(master_csv, index=False)
    print("✅ Saved master CSV:", master_csv)

    # Create grouped and atomic files (both CSV + ARFF)
    generate_set_files(df, class_names)
    generate_many_files(df, class_names)

    print("🏁 DONE. Now you can compare many datasets in Weka.")

if __name__ == "__main__":
    main()
