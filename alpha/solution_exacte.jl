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

function solution_exacte(nom_fichier, p)
    solution_x, solution_z, n, tabX, tabY = resoudre_p_centre(nom_fichier, p)
    
    S = [0 for _ in 1:n]
    for j in 1:n
        if solution_x[j, j] >= 0.5
            S[j] = 1
        end
    end
    
    Dessine_UFLP(nom_fichier, n, tabX, tabY, S)
end