# ANALIZA ECONOMETRICĂ: REGRESIE LOGISTICĂ ȘI AUDIT DE ECHITATE
# PASUL 1: Încărcare pachete specifice
packages <- c("dplyr", "ggplot2", "car", "lmtest", "readxl", "vcd")
installed <- packages %in% rownames(installed.packages())
if (any(!installed)) install.packages(packages[!installed])
invisible(lapply(packages, library, character.only = TRUE))

# PASUL 2: Import date și pregătire variabile
# Presupunem datele exportate din SQL în Excel
date_credit <- read_excel("Fintech_Credit_Data.xlsx")

# Codificăm variabila dependentă (Aprobat = 1, Respins = 0)
date_credit$y <- ifelse(date_credit$application_status == "Approved", 1, 0)
date_credit$Gender_F <- as.factor(date_credit$gender)

# PASUL 3: Estimare Model de Regresie Logistică (LOGIT)
# Obiectiv: Vedem dacă 'Gender' sau 'Age' influențează probabilitatea de aprobare
model_logit <- glm(y ~ Annual_Income + Credit_Score + age + Gender_F, 
                   data = date_credit, 
                   family = binomial(link = "logit"))

summary(model_logit)

# Interpretare:
# p-value pentru Gender_F < 0.05 => Există discriminare statistic semnificativă.
# exp(coef) ne dă Odds Ratio (Șansele de aprobare)
odds_ratios <- exp(coef(model_logit))
round(odds_ratios, 3)

# PASUL 4: Testarea Ipotezelor și Diagnosticare
# 4.1. Testul Multicoliniaritate (VIF)
# Verificăm dacă variabilele independente sunt independente între ele
vif(model_logit)

# 4.2. Testul de semnificație globală (Likelihood Ratio Test)
# H0: Modelul fără predictori este la fel de bun (Modelul este nul)
# H1: Modelul este valid global
lrtest(model_logit)

# PASUL 5: Auditul de Echitate (Statistical Fairness Test)
# Folosim Testul Chi-Pătrat pentru a identifica disparitățile de aprobare
tabel_contingenta <- table(date_credit$gender, date_credit$application_status)
print(tabel_contingenta)

# Calculăm Rata de Selecție (Adverse Impact Ratio)
# Dacă raportul este sub 0.8, conform regulii "4/5th rule", există bias sever
prop_table <- prop.table(tabel_contingenta, 1)
air <- prop_table[2,2] / prop_table[1,2] # Rata Femei / Rata Bărbați
air

# PASUL 6: Vizualizarea Probabilităților (Impact Uman)
# Curba sigmoidală pentru Scorul de Credit în funcție de Gen
ggplot(date_credit, aes(x = Credit_Score, y = y, color = gender)) +
  geom_point(alpha = 0.2) +
  geom_smooth(method = "glm", method.args = list(family = "binomial"), se = FALSE) +
  labs(title = "Probabilitatea de Aprobare: Analiză de Disparitate",
       x = "Credit Score", y = "Probabilitate (0-1)") +
  theme_minimal()


