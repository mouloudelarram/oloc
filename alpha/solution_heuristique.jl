include("./IO_UFLP.jl");

using Random

function density_based_selection(n, p, tabX, tabY)
    # Calculer la densité des points
    densities = zeros(Float64, n)
    for i in 1:n
        for j in 1:n
            if i != j
                densities[i] += 1 / dist(tabX[i], tabY[i], tabX[j], tabY[j])
            end
        end
    end
    # Trier les points par densité décroissante
    sorted_indices = sortperm(densities, rev=true)
    # Sélectionner les p points avec la plus haute densité
    antennas = zeros(Int, n)
    for i in 1:p
        antennas[sorted_indices[i]] = 1
    end
    return antennas
end

function iterative_farthest_selection(n, p, tabX, tabY)
    antennas = zeros(Int, n)
    # Initialiser avec un point aléatoire
    initial_point = rand(1:n)
    antennas[initial_point] = 1

    for _ in 2:p
        max_distance = 0.0
        farthest_point = 0

        for i in 1:n
            if antennas[i] == 0
                min_distance_to_antenna = Inf
                for j in 1:n
                    if antennas[j] == 1
                        min_distance_to_antenna = min(min_distance_to_antenna, dist(tabX[i], tabY[i], tabX[j], tabY[j]))
                    end
                end
                if min_distance_to_antenna > max_distance
                    max_distance = min_distance_to_antenna
                    farthest_point = i
                end
            end
        end
        antennas[farthest_point] = 1
    end
    return antennas
end


function solution_heuristique_densite(nom_fichier, p) 
    tabX = Float64[]
    tabY = Float64[]
    n = Lit_fichier_UFLP(nom_fichier, tabX, tabY, [])
    S = density_based_selection(n, p, tabX, tabY)
    Dessine_UFLP(nom_fichier, n, tabX, tabY, S);
end

function solution_heuristique_iterative_farthest(nom_fichier, p) 
    tabX = Float64[]
    tabY = Float64[]
    n = Lit_fichier_UFLP(nom_fichier, tabX, tabY, [])
    S = iterative_farthest_selection(n, p, tabX, tabY)
    Dessine_UFLP(nom_fichier, n, tabX, tabY, S);
end