using JuMP
using CPLEX

function solve_linear_relaxation(n, p, d)
    model = Model(CPLEX.Optimizer)

    @variable(model, 0 <= x[1:n, 1:n] <= 1)
    @variable(model, z >= 0)

    @objective(model, Min, z)
    
    @constraint(model, sum(x[j,j] for j in 1:n) <= p)
    for i in 1:n
        @constraint(model, sum(x[i,j] for j in 1:n) == 1)
        for j in 1:n
            if i != j
                @constraint(model, x[i,j] <= x[j,j])
            end
        end
    end

    for i in 1:n
        @constraint(model, sum(d[i,j]*x[i,j] for j in 1:n) <= z)
    end

    optimize!(model)

    x_opt = value.(x)
    z_opt = value(z)

    return x_opt, z_opt
end

function round_solution(x_opt, n, p)
    # Initialiser les antennes
    antennas = zeros(Int, n)
    
    # Calculer la somme des x_opt[j,j] pour chaque j
    scores = [sum(x_opt[i,j] for i in 1:n) for j in 1:n]
    
    # Trouver les p plus grands scores
    sorted_indices = sortperm(scores, rev=true)
    selected_points = sorted_indices[1:p]
    
    for j in selected_points
        antennas[j] = 1
    end
    
    return antennas
end

function solution_relaxation_lineaire(nom_fichier, p)
    tabX = Float64[]
    tabY = Float64[]
    n = Lit_fichier_UFLP(nom_fichier, tabX, tabY, [])

    # Calculer les distances euclidiennes
    d = [dist(tabX[i], tabY[i], tabX[j], tabY[j]) for i in 1:n, j in 1:n]

    # Résoudre la relaxation linéaire
    x_opt, z_opt = solve_linear_relaxation(n, p, d)
    println("Solution fractionnaire x_opt : ", x_opt)

    # Arrondir la solution
    antennas_rounded = round_solution(x_opt, n, p)
    println("Antennes placées après arrondissement : ", findall(x -> x == 1, antennas_rounded))

    # Visualiser la solution arrondie
    Dessine_UFLP(nom_fichier, n, tabX, tabY, antennas_rounded)
end