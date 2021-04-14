##### Algoritmo de Piotroski ###############################################
##### 03/08/2020 ###########################################################
##### Bruno Marcelino ######################################################
##### Empresas: LAME4, BTOW3.SA, LREN3, PCAR3, VVAR4.SA ####################
##### Análise Aplicada ao Setor Varejista Entre os Anos de 2013 e 2019 #####

# Importações de Bibliotecas

library("quantmod")
library("xlsx")
library("tidyverse")

# Podemos escolher diversos arquivos. O padrão utilizará dados das Lojas Renner S.A

data <- read.xlsx("data/LREN3.xlsx", sheetName = "LREN3", as.data.frame = TRUE)

# data <- read.xlsx("data/LAME4.xlsx", sheetName = "LAME4", as.data.frame = TRUE)
# data <- read.xlsx("data/BTOW3.xlsx", sheetName = "BTOW3", as.data.frame = TRUE)
# data <- read.xlsx("data/PCAR3.xlsx", sheetName = "PCAR3", as.data.frame = TRUE)
# data <- read.xlsx("data/VVAR4.xlsx", sheetName = "VVAR4", as.data.frame = TRUE)

##
### Tratamento dos Dados
##

colnames(data) <- c("Data",
                     "ROA",
                     "Delta ROA",
                     "Delta Alavancagem",
                     "Delta Liquidez Corrente",
                     "Delta Quantidade de Ações",
                     "Margem Bruta",
                     "Delta Giro do Ativo",
                     "Lucro Líquido",
                     "FCO",
                     "LPA",
                     "CDI")

dados <- data %>%
    mutate(FCO = as.numeric(ifelse(FCO == "-", 0, FCO))) 

##
### Montando a pontuação de cada indicador
##

# 1) ROA = Lucro Líquido Anual / Ativos 

vetor_1 <- ifelse(dados$ROA > 0, 1, 0)
vetor_1 <- vetor_1[17:44]

# 2) FCO = Resultado Financeiro  

vetor_2 <- ifelse(dados$FCO > 0, 1, 0)
vetor_2 <- vetor_2[17:44]

# 3) Delta ROA 

ROA_lag <- Lag(dados$`ROA`, k = 1)
vetor_3 <- ifelse(dados$`ROA` > ROA_lag, 1, 0)
vetor_3[1] = 0
vetor_3 <- vetor_3[17:44]

# 4) Accrual = FCO > LL ano

vetor_4 <- ifelse(dados$FCO > dados$`Lucro Líquido` , 1, 0)
vetor_4 <- vetor_4[17:44]

# 5) Delta Alavancagem = Dívidas / Ativos Totais  

vetor_5 <- ifelse(dados$`Delta Alavancagem` < 0, 1, 0)
vetor_5 <- vetor_5[17:44]

# 6) Delta Liquidez Corrente = Ativo Circulante / Passivo Circulante  

vetor_6 <- ifelse(dados$`Delta Liquidez Corrente` > 0, 1, 0)
vetor_6 <- vetor_6[17:44]

# 7) Delta Total de Ações 

vetor_7 <- ifelse(dados$`Delta Quantidade de Ações` <= 0, 1, 0)
vetor_7 <- vetor_7[17:44]

# 8) Delta Margem Bruta = Lucro Bruto / Receita Líquida 

Margem_Bruta_lag <- Lag(dados$`Margem Bruta`, k = 1)

vetor_8 <- ifelse(dados$`Margem Bruta` > Margem_Bruta_lag, 1, 0)
vetor_8 <- vetor_8[17:44]

# 9) Variação do Giro do Ativo = Receita Líquida / Média dos Ativos Totais (últimos 12 meses) 

vetor_9 <- ifelse(dados$`Delta Giro do Ativo` > 0, 1, 0)
vetor_9 <- vetor_9[17:44]

##
### Somando e encontrando a pontuação anual da empresa 
##

pontuações <- data.frame(vetor_1,
                         vetor_2, 
                         vetor_3,
                         vetor_4,
                         vetor_5,
                         vetor_6,
                         vetor_7,
                         vetor_8,
                         vetor_9)

data_pesos <- data.frame("Data" = dados$Data[17:44], "Pesos" = rowSums(pontuações))

data_pesos$Sinais <- ifelse(data_pesos$Pesos >= 7, 1,
                            ifelse(data_pesos$Pesos <= 2, -1, 0))   

##
### Backtest
##

## Dados

# Periodo de Analise
startdate <- as.Date("2012-12-31")
enddate <- as.Date("2019-12-30")

# Selecao do ativo para analise
tickers <- c("LREN3.SA")

# Captura dos dados
getSymbols(tickers, src = "yahoo", from = startdate, to = enddate)

## Aplicando os Sinais nos Trades: ano a ano

data_pesos$retorno_trimestre <- quarterlyReturn(LREN3.SA)

data_pesos$Lag_Sinais <- Lag(data_pesos$Sinais, k = 1)

data_pesos$CDI <- dados$CDI[17:44]

data_pesos$trades <- ifelse(data_pesos$Lag_Sinais == 1, data_pesos$retorno_trimestre, 
                            
                            ifelse(data_pesos$Lag_Sinais == -1, -data_pesos$retorno_trimestre, data_pesos$CDI) 
                            
                            
)

data_pesos[1, c(5,7)] <- 0
data_pesos$trades <- as.numeric(data_pesos$trades)

data_pesos$retorno_indices <- (1+data_pesos$trades)
data_pesos$retorno_indices <- ifelse(data_pesos$retorno_indices < 0 , -data_pesos$retorno_indices, data_pesos$retorno_indices) #corrigir índices negativos (não existe índice < 0)

valores_faltantes <- c(-1, -length(data_pesos$retorno_indices))
retorno_acumulado <- round(((prod(data_pesos$retorno_indices[valores_faltantes]))-1)*100,2)
print(paste("O retorno acumulado do modelo foi de",retorno_acumulado, "%"))

data_pesos$CDI <- as.numeric(data_pesos$CDI)
retorno_CDI_indices <- (1+data_pesos$CDI)
retorno_CDI <- round(((prod(retorno_CDI_indices[valores_faltantes]))-1)*100,2)
print(paste("O retorno do nosso benchmark, o CDI, foi de",retorno_CDI,"%"))
