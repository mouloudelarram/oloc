include("./IO_UFLP.jl");

using Random

# Fonction pour tirer p points au hasard parmi n
function tirer_points_au_hasard(n, p)
    return sort(randperm(n)[1:p])
end

# Fonction Dessine instance avec les points tir�s au hasard en rouge et sauvegarde en PNG
function Dessine_UFLP_aleatoire(nom_fichier, p)
    tabX = Float64[]
    tabY = Float64[]
    f= Float64[]
    
    println("Lecture du fichier: ", nom_fichier)
    n = Lit_fichier_UFLP(nom_fichier, tabX, tabY, f)
    println("Le fichier contient ", n, " villes")
    
    if p > n
        println("Erreur : p ne peut pas etre superieur au nombre de villes.")
        return
    end

    # Tirer p points au hasard
    points_rouges = tirer_points_au_hasard(n, p)
    
    #nom_fichier_en_deux_morceaux = split(nom_fichier, ".")
    nom_fichier_avec_png_a_la_fin =  nom_fichier *  "_aleatoire.png"
    println("Creation du fichier png de l'instance: ", nom_fichier_avec_png_a_la_fin)
    
    # Affichage des points
    Plots.plot(tabX, tabY, seriestype = :scatter, color=:blue, legend=false)
    
    # Affichage des points tir�s au hasard en rouge
    Plots.scatter!(tabX[points_rouges], tabY[points_rouges], color=:red)
    
    Plots.savefig(nom_fichier_avec_png_a_la_fin)
end


# Exemple d'utilisation
 Dessine_UFLP_aleatoire("./Instances/inst_50000.flp", 25)