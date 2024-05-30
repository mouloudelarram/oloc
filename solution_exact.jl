include("./IO_UFLP.jl");

using JuMP
using CPLEX



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
function Dessine_UFLP_solution(nom_fichier, solution_x, tabX, tabY)
    n = size(solution_x, 1)
    
    scatter_x = Float64[]
    scatter_y = Float64[]
    assigned = zeros(n)  # Un tableau pour suivre quelles villes ont déjà été assignées comme antenne
    
    for i in 1:n
        if solution_x[i, i] > 0.5 && assigned[i] == 0  # Si la ville i est assignée comme une antenne et n'est pas déjà assignée red
            push!(scatter_x, tabX[i])
            push!(scatter_y, tabY[i])
            assigned[i] = 1  # Marquer la ville i comme assignée
            break
        end
    end
    
    scatter(tabX, tabY, label="Villes", color="blue")
    scatter!(scatter_x, scatter_y, label="Antennes", color="red")
    xlabel!("Coordonnée X")
    ylabel!("Coordonnée Y")
    title!("Disposition des villes et des antennes")
    
    savefig(nom_fichier * "_solution3.png")
end


function Dessine_UFLP_exact(nom_fichier, p) 
    solution_x, solution_z, n, tabX, tabY = resoudre_p_centre(nom_fichier, p)
    Dessine_UFLP_solution(nom_fichier, solution_x, tabX, tabY)
end


# Exemple d'utilisation


