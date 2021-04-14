O código tem como finalidade simular o backtest de um modelo quantitativo de fatores, criado por um professor da Universidade de Stanford chamado Joseph Piotroski. Simplificadamente, cada fator a ser avaliado receberá uma pontuação, e os parâmetros de compra e venda das ações da empresa analisada estarão condicionados a sua pontuação agregada ao longo dos 9 (nove) fatores. O arquivo "f-score.pdf" ilustra o resumo do artigo no qual retiramos a motivação da inclusão de cada fator a ser incluído no projeto. 

Para rodar o código com outros bancos de dados (foram incluídos 5 (cinco) no total, todos retirados da plataforma Economatica) basta alterar duas coisas: 

* Uma é o caminho até o arquivo, que se resume em selecionar uma das linhas em que declaro uma das variáveis e retirar o "#" (fazendo com que ela não seja lida como comentário e sim como parte do código a ser compilado).

* Outra é alterar o ticker do ativo nas linhas 125 e 132, de acordo com sua nomeação no Yahoo Finance. Nesse código, basta acrescentar o sufixo ".SA" após o ticker do ativo. 