import json

class CCIAIAuditSimulator:
    def __init__(self, target_budget_eur=69000):
        self.target_budget = target_budget_eur
        self.raised_funds = 0
        self.expenses = []

    def simulate_crypto_donation(self, donor_name, amount_eur):
        self.raised_funds += amount_eur
        print(f"[DONATIE] {donor_name} a contribuit cu {amount_eur} EUR.")
        self.check_milestone()

    def record_expense(self, category, amount_eur, description):
        if self.raised_funds >= amount_eur:
            self.raised_funds -= amount_eur
            self.expenses.append({"categorie": category, "suma": amount_eur, "detalii": description})
            print(f"[CHELTUIALA APROBATA] {category}: {amount_eur} EUR -> {description}")
        else:
            print(f"[EROARE] Fonduri insuficiente pentru: {description}")

    def check_milestone(self):
        progress = (self.raised_funds / self.target_budget) * 100
        print(f"-> Progres finanțare totală: {progress:.2f}% ({self.raised_funds}/{self.target_budget} EUR)\n")

# Exemplu de rulare a fluxului de management financiar CCIAI
if __name__ == "__main__":
    hub = CCIAIAuditSimulator()
    
    print("--- INCEPERE SIMULARE FINANCARE CCIAI ---")
    hub.simulate_crypto_donation("Diaspora US", 25000)
    hub.simulate_crypto_donation("Fond DeFi Impact", 44000)
    
    print("--- ALOCARE RESURSE CONFORM BUGETULUI ---")
    hub.record_expense("Infrastructură & Închiriere", 18000, "Chirie sediu + utilități 1 an")
    hub.record_expense("Echipamente & Amenajare", 6000, "Calculatoare, imprimante, seturi șah, remi, go")
    hub.record_expense("Resurse Umane", 20000, "Avans salarii Coordonator și Profesor limbă")
