//Aluno: Francilândio Lima Serafim (472644)

//--------------------------Informações--------------------------------
//Para implementar o algoritmo genético foi escolhido usar o método do torneio para seleção dos pais por ser a forma mais simples.
//Para o cruzamento foram implementadas 3 formas selecionáveis: Corte por um ponto, corte por dois pontos e uniforme.
//Um gráfico é plotado mostrando a superfície formada pela função, a população da última geração e o ponto mínimo destacado.
//Em geral foram obtidos melhores resultados usando uma taxa de mutação entre 10% e 15%, taxas entre 0% e 1% resultaram em valores ruins.
//---------------------------------------------------------------------

clc;
clear;

//Seleção de pais através do método Torneio
function pais = torneio(populacao, notas, num_individuos)
    pais = zeros(40, num_individuos);
    //O número de torneios equivale ao tamanho da população
    for i = 1:length(notas)
        //Escolhe dois indivíduos aleatoriamente
        ind1 = ceil(rand(1, 1) * num_individuos);
        ind2 = ceil(rand(1, 1) * num_individuos);
        //O problema em questão privilegia indivíduos com menores avaliações
        if notas(ind1) < notas(ind2) then
            pais(:, i) = populacao(:, ind1)
        else
            pais(:, i) = populacao(:, ind2)
        end
    end
endfunction

//Cruzamento através do Crossover uniforme
function filhos = crossover_uniforme(pais, num_individuos)
    //Vetor de combinação
    combinacao = rand(40, 1);
    //Conversão para binário
    for i = 1:length(combinacao)
        if combinacao(i) < 0.5 then
            combinacao(i) = 0
        else
            combinacao(i) = 1
        end
    end
    //Todo par de pais gera um par de filhos
    for i = 1:2:num_individuos 
        for j = 1:40
            if combinacao(j) == 1 then
                //Primeiro filho herda do primeiro pai
                filhos(j, i) = pais(j, i);
                //Segundo filho herda do segundo pai
                filhos(j, i+1) = pais(j, i+1);
            else
                //Primeiro filho herda do segundo pai
                filhos(j, i) = pais(j, i+1);
                //Segundo filho herda do primeiro pai
                filhos(j, i+1) = pais(j, i);
            end
        end
    end
endfunction

//Cruzamento através do Crossover de 1 ponto
function filhos = crossover_singular(pais, num_individuos)
    //Todo par de pais gera um par de filhos
    for i = 1:2:num_individuos 
        ponto_corte = ceil(rand(1, 1) * 39);
        //Primeiro filho: parte esquerda do pai 1 + parte direita do pai 2
        filhos(:, i) = [pais(1:ponto_corte, i) ; pais(ponto_corte+1:40, i+1)];
        //Segundo filho: parte esquerda do pai 2 + parte direita do pai 1
        filhos(:, i+1) = [pais(1:ponto_corte, i+1) ; pais(ponto_corte+1:40, i)];
    end
endfunction

//Cruzamento através do Crossover com dois pontos de corte
function filhos = crossover_duplo(pais, num_individuos)
    //Todo par de pais gera um par de filhos
    for i = 1:2:num_individuos 
        ponto_corte_1 = ceil(rand(1, 1) * 39);
        ponto_corte_2 = ceil(rand(1, 1) * 39);
        if(ponto_corte_1 <= ponto_corte_2) then
            //Primeiro filho: parte esquerda do pai 1 + parte central do pai 2 + parte direita do pai 1
            filhos(:, i) = [pais(1:ponto_corte_1, i) ; pais(ponto_corte_1+1:ponto_corte_2, i+1); pais(ponto_corte_2+1:40, i)];
            //Segundo filho: parte esquerda do pai 2 + parte central do pai 1 + parte direita do pai 2
            filhos(:, i+1) = [pais(1:ponto_corte_1, i+1) ; pais(ponto_corte_1+1:ponto_corte_2, i); pais(ponto_corte_2+1:40, i+1)];
        else
            //Primeiro filho: parte esquerda do pai 1 + parte central do pai 2 + parte direita do pai 1
            filhos(:, i) = [pais(1:ponto_corte_2, i) ; pais(ponto_corte_2+1:ponto_corte_1, i+1); pais(ponto_corte_1+1:40, i)];
            //Segundo filho: parte esquerda do pai 2 + parte central do pai 1 + parte direita do pai 2
            filhos(:, i+1) = [pais(1:ponto_corte_2, i+1) ; pais(ponto_corte_2+1:ponto_corte_1, i); pais(ponto_corte_1+1:40, i+1)];
        end
    end
endfunction

//Função que implementa a mutação nas populações
function mutantes = mutacao(filhos, taxa_mutacao, num_individuos)
    mutantes = filhos;
    for i = 1:num_individuos
        //Percorre todo o cromossomo, assim qualquer gene pode ou não ser modificado
        for j = 1:40
            sorteado = rand(1, 1); //número randômico entre 0 e 1
            //Inversão de bit ocorre se o número sorteado for menor que a taxa de mutação informada
            if sorteado < taxa_mutacao then 
                if mutantes(j, i) == 0 then
                    mutantes(j, i) = 1;
                else
                    mutantes(j, i) = 0;
                end
            end
        end
    end
endfunction

//Função de Eggholder
function f = eggholder(x, y)
    f = -(y + 47).*sin(sqrt(abs(x/2 + y + 47))) - x.*sin(sqrt(abs(x - (y + 47))))
endfunction

//----------------Definição dos parâmetros------------------
mprintf("Recomendações:\nPopulação inicial = 100\nNúmero de gerações = 20\nTaxa de mutação = 10\nCruzamento = 2.")
mprintf("\n================================================================");
n_individuos = input("Digite o número de indivíduos na população inicial: ");
geracoes = input("Digite o número de gerações: ");
taxa = input("Digite qual taxa de mutação deseja(0 - 100): ")/100; //Recebe o valor em porcentagem e converte para decimal.
tipo_cruzamento = input("Informe o tipo de cruzamento(1 - um ponto de corte; 2 - uniforme; 3 - dois pontos de corte): ");
mprintf("================================================================");

pop_inicial = rand(40, n_individuos, 'uniform'); //População inicial com indivíduos de 40 elementos cada.

//Cada indivíduo tem 40 números entre 0 e 1, a seguir binarizamos todos eles na população inicial
for i = 1:size(pop_inicial)(1)
    for j = 1:size(pop_inicial)(2)
        if pop_inicial(i, j) < 0.5 then
            pop_inicial(i, j) = 0
        else
            pop_inicial(i, j) = 1
        end
    end
end

//O critério de parada é o número de gerações
for g = 1:geracoes 
    //Os 20 primeiros bits de cada indivíduo representa x, então fazemos essa distinção
    for i = 1:20
        for j = 1:size(pop_inicial)(2)
            x(j) = strcat(string(pop_inicial(1:20, j)))  
        end
    end
    //Os 20 últimos bits de cada indivíduo representa y, então fazemos essa distinção
    for i = 21:40
        for j = 1:size(pop_inicial)(2)
            y(j) = strcat(string(pop_inicial(21:40, j)))  
        end
    end
    //vetor x convertido para decimal
    x_decimal = bin2dec(x)
    //vetor y convertido para decimal
    y_decimal = bin2dec(y)
    //convertendo x para o intervalo dado [400, 600]
    x_conv = (((x_decimal - min(x_decimal)) .* (600 - 400)) ./ (max(x_decimal) - min(x_decimal))) + 400
    //convertendo y para o intervalo dado [400, 600]
    y_conv = (((y_decimal - min(y_decimal)) .* (600 - 400)) ./ (max(y_decimal) - min(y_decimal))) + 400
    //coletando as avaliações
    notas = eggholder(x_conv, y_conv)
    //selecionando os pais pelo método de torneio
    pais = torneio(pop_inicial, notas, n_individuos);
    //Verificando o tipo de cruzamento escolhido
    if tipo_cruzamento == 1 then
            pop_inicial = crossover_singular(pais, n_individuos);
    elseif tipo_cruzamento == 2 then
            pop_inicial = crossover_uniforme(pais, n_individuos);
    elseif tipo_cruzamento == 3 then
            pop_inicial = crossover_duplo(pais, n_individuos);
    end
    //realizando a mutação da população
    pop_inicial = mutacao(pop_inicial, taxa, n_individuos);
end

//Obtendo o índice do indivíduo com menor nota na última geração
minimo = find(notas == min(notas));

x_min = x_conv(minimo); //x do ponto mínimo
y_min = y_conv(minimo); //y do ponto mínimo
f_min = notas(minimo); //Valor mínimo encontrado de f 

mprintf("\nCoordenada x do melhor indivíduo: %f\n", x_min);
mprintf("\nCoordenada y do melhor indivíduo: %f\n", y_min);
mprintf("\nValor de f(x,y) do melhor indivíduo: %f\n", f_min);

//---------------------------Parte gráfica-------------------------------------
x=linspace(400, 600, 40);
y=linspace(400, 600, 40);
for n = 1:40
    for m = 1:40
        z(n, m)= eggholder(x(n), y(m))
    end    
end
grafico = gcf();
grafico.color_map = coppercolormap(10);
plot3d(x, y, z);
title('População da última geração (' + string(geracoes) + ').','color','darkblue','edgecolor','red','fontsize',5);
//Plotando os pontos e as notas da última geração
scatter3d(x_conv, y_conv, notas, 15, 'orange', "fill");
scatter3d([x_min x_min], [y_min y_min], [f_min f_min], 30, 'blue', "fill", "x"); //Localizando o ponto de mínimo obtido.
legend('População','Ponto de mínimo obtido',2);
