"""
=======================================================
  Student Performance — Tam Python Analitik Skripti
=======================================================
Dataset: 1000 tələbənin riyaziyyat, oxuma, yazı balları
Müəllif: Claude (Anthropic)
"""

import pandas as pd
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import seaborn as sns
import sqlite3
import warnings
warnings.filterwarnings('ignore')

# ── 1. VERİLƏNLƏRİ YÜKLƏ ──────────────────────────────────────────────────────
df = pd.read_excel("performancepivot.xlsx", sheet_name="StudentsPerformance")
df.columns = ['gender','race_ethnicity','parental_education','lunch',
              'test_prep','math_score','reading_score','writing_score']
df['student_id']    = range(1, len(df)+1)
df['average_score'] = (df['math_score'] + df['reading_score'] + df['writing_score']) / 3
df['total_score']   = df['math_score'] + df['reading_score'] + df['writing_score']
df['grade'] = pd.cut(df['average_score'],
                     bins=[0,60,70,80,90,100],
                     labels=['F','D','C','B','A'],
                     right=True)

# ── 2. EDA ────────────────────────────────────────────────────────────────────
print("="*55)
print("  DATASET HAQQINDA")
print("="*55)
print(f"Cəmi tələbə : {len(df)}")
print(f"Sütunlar    : {list(df.columns)}")
print(f"Null dəyər  : {df.isnull().sum().sum()}")
print()
print(df[['math_score','reading_score','writing_score','average_score']].describe().round(2))

# ── 3. KORRELYASIYA ────────────────────────────────────────────────────────────
print("\nKorrelyasiya matrisi:")
print(df[['math_score','reading_score','writing_score']].corr().round(3))

# ── 4. QRUPLAR ÜZRƏ ANALİZ ────────────────────────────────────────────────────
print("\n--- Cinslər üzrə ---")
print(df.groupby('gender')[['math_score','reading_score','writing_score','average_score']].mean().round(2))

print("\n--- Test hazırlığı üzrə ---")
print(df.groupby('test_prep')[['math_score','reading_score','writing_score']].mean().round(2))

print("\n--- Etnik qrup üzrə (ümumi sıralama) ---")
print(df.groupby('race_ethnicity')['average_score'].mean().sort_values(ascending=False).round(2))

print("\n--- Valideyn təhsili üzrə ---")
edu_order = ['some high school','high school',"associate's degree",
             'some college',"bachelor's degree","master's degree"]
print(df.groupby('parental_education')['average_score'].mean().reindex(edu_order).round(2))

# ── 5. KECİD FAİZİ ────────────────────────────────────────────────────────────
print("\n--- Kecid faizləri (>=60) ---")
for col in ['math_score','reading_score','writing_score']:
    pct = (df[col] >= 60).mean() * 100
    print(f"  {col:<20}: {pct:.1f}%")

# ── 6. GRADE BÖLGÜSÜ ──────────────────────────────────────────────────────────
print("\n--- Qiymət bölgüsü ---")
print(df['grade'].value_counts().sort_index())
