include("./IO_UFLP.jl");

using JuMP
using CPLEX
using Plots
using Colors

function dist(x1, y1, x2, y2)
    return sqrt((x1 - x2)^2 + (y1 - y2)^2)
end

function resoudre_p_centre(nom_fichier, p)
    tabX = Float64[]
    tabY = Float64[]
    n = Lit_fichier_UFLP(nom_fichier, tabX, tabY, [])
    dij = zeros(n, n)
    for i in 1:n
        for j in 1:n
            dij[i, j] = sqrt((tabX[i] - tabX[j])^2 + (tabY[i] - tabY[j])^2)
        end
    end
    
    model = Model(CPLEX.Optimizer)
    @variable(model, x[1:n, 1:n], Bin)
    @variable(model, z >= 0)
    @constraint(model, sum(x[j, j] for j in 1:n) <= p)
    for i in 1:n
        @constraint(model, sum(x[i, j] for j in 1:n) == 1)
        for j in 1:n
            if i != j
                @constraint(model, x[i, j] <= x[j, j])
            end
        end
        @constraint(model, sum(dij[i, j] * x[i, j] for j in 1:n) <= z)
    end
    @objective(model, Min, z)
    
    optimize!(model)
    
    solution_x = value.(x)
    solution_z = value(z)
    
    return solution_x, solution_z, n, tabX, tabY
end

function Dessine_UFLP(nom_fichier, n, tabX, tabY, S, solution_x, solution_z)
    X = Float64[]
    Y = Float64[]
    
    nom_fichier_en_deux_morceaux = split(nom_fichier, ".")
    nom_fichier_avec_pdf_a_la_fin = nom_fichier_en_deux_morceaux[1] * "_sol.pdf"
    
    println("Création du fichier pdf de la solution: ", nom_fichier_avec_pdf_a_la_fin)
    
    plot(tabX, tabY, seriestype = :scatter, legend = false, color=:blue)
    
    for i in 1:n
        if S[i] == 1
            scatter!([tabX[i]], [tabY[i]], color=:red, legend=false)
        end
    end
    
    for i in 1:n
        min = 10e10
        minj = 0
        for j in 1:n
            if (S[j] == 1) && (min > dist(tabX[i], tabY[i], tabX[j], tabY[j]))
                min = dist(tabX[i], tabY[i], tabX[j], tabY[j])
                minj = j
            end
        end
        if i != minj
            empty!(X)
            empty!(Y)
            push!(X, tabX[i])
            push!(X, tabX[minj])
            push!(Y, tabY[i])
            push!(Y, tabY[minj])
            
            color = min == solution_z ? :orange : get_color(min, solution_z)
            plot!(X, Y, linecolor=color, legend=false)
        end
    end
    
    savefig(nom_fichier_avec_pdf_a_la_fin)
end

function get_color(distance, max_distance)
    norm_distance = distance / max_distance
    dark_green = RGB(0.0, 0.5, 0.0)
    light_green = RGB(0.5, 1.0, 0.5)
    r = dark_green.r + norm_distance * (light_green.r - dark_green.r)
    g = dark_green.g + norm_distance * (light_green.g - dark_green.g)
    b = dark_green.b + norm_distance * (light_green.b - dark_green.b)
    return RGB(r, g, b)
end

function dessin_solution_exacte(nom_fichier, p)
    solution_x, solution_z, n, tabX, tabY = resoudre_p_centre(nom_fichier, p)
    
    S = [0 for _ in 1:n]
    for j in 1:n
        if solution_x[j, j] >= 0.5
            S[j] = 1
        end
    end
    
    Dessine_UFLP(nom_fichier, n, tabX, tabY, S, solution_x, solution_z)
end

# Exemple d'utilisation
# nom_fichier = "nom_de_votre_fichier.flp"
# p = 5
# dessin_solution_exacte(nom_fichier, p)
