include("./IO_UFLP.jl");

using Random

# Fonction pour générer une solution aléatoire
function solution_aleatoire(nom_fichier, p)
    n=0
    tabX=Float64[]
    tabY=Float64[]
    f= Float64[]
    
    println("Lecture du fichier: ", nom_fichier)

    n= Lit_fichier_UFLP(nom_fichier, tabX, tabY, f)

    S = zeros(Int, n)
    indices = randperm(n)[1:p]  # Sélectionner p indices aléatoires
    for i in indices
        S[i] = 1
    end
    
    Dessine_UFLP(nom_fichier, n, tabX, tabY, S);
end
