Reunião de Orientação, 19/06/2025 - TCC1 Emir Bráz de Araújo Marques Júnior
Presentes: Emir e Ney
Link do Googledrive para materiais do TCC do Emir: https://drive.google.com/drive/folders/1DBpFxflJj4FA5cEN1k_TOdPidxexRXPg?ths=true

1) Em reunião anterior, não documentada com ata (acho que em 27/05/2025...), decidimos mudar o foco do trabalho. Ao invés de desenvolver um módulo para habilitar realizar DMA no RISC-V da PUCRS, Ney propôs algo menos ambicioso. A nova proposta é inserir no processador didático MIPS_S, desenvolvido por colegas da PUCRS e Ney, a capacidade para lidar adequadamente com periféricos externos e responder a exceções. A MIPS_S é um processador que implementa um subconjunto das instruções da arquitetura MIPS em sua encarnação MIPS2000 (ou MIPS32, usando nomenclatura mais moderna). Isto será feito incorporando um Coprocessador 0 (CP0) ao MIPS_S, seguindo ao máximo a padronização deste módulo como previsto para a arquitetura MIPS32. A motivação para tanto é múltipla:
	1.1) O trabalho proposto para o TCC do Gabriel Lencina acabou por se revelar desafiador demais, devido ao parco domínio da arquitetura (PUCRS-RS5) pelo aluno e mesmo pelos seus orientadores. Neste momento, é melhor aumentar o domínio deste pelos orientadores, antes de empreender novo trabalho de pesquisa e desenvolvimento com este ambiente. 
	1.2) O MIPS_S é completamente dominado por Ney, o que facilita a orientação e apoio à nova proposta de TCC por Emir.
	1.3) O MIPS_S é uma máquina multiciclo, não-pipeline. Isto mais uma vez facilita trabalhar com sua descrição de Hw.

2) Na reunião de hoje, Ney mostrou múltiplos detalhes de como o trabalho deve ser organizado, usando a distribuição da MIPS_S já repassada para Emir. Uma proposta que Ney trouxe é organizar o TCC de Emir no conjunto de 5 macro-tarefas a seguir:
	2.1) (Hw) Adicionar as novas instruções da arquitetura MIPS32, aquelas minimamente necessárias para dar suporte ao CP0. São 15 instruções nesta categoria:
		mfco, mtc0, eret, teq, teqi, tne, tnei, tge, tgeu, tgei, tgeiu, tlt, tltu, tlti e tltiu.
		Obs: Com a prática que Ney tem com a organização MIPS_S atual, Ney propõe que ele realize esta parte do trabalho e disponibilize o resultado do mesmo para o TCC de Emir. Ney deve, entretanto prover a Emir o seguinte durante ou após o processo de gerar uma organização estendida para dar suporte às 15 novas instruções acima: (1) Uma explicação de como se opera, em geral, o processo de criar novas instruções da arquitetura MIPS no Hw da MIPS_S; (2) Como se deve sistematicamente alterar o Hw da MIPS_S para incorporar cada nova instrução, a partir das especificidades de cada uma das novas instruções; (3) Discutir com Emir o processo empregado para validar a execução das novas instruções no novo Hw da MIPS_S (a nível de testbench e outros níveis eventuais). Será importante Emir entender este processo, pois ele vai finalmente documentar o que foi realizado nesta macro-tarefa no seu texto de TCC.
	2.2) (Hw+Sw) Projetar e implementar o CP0 para a MIPS_S, assumindo a nova versão desenvolvida na macro-tarefa 2.1. Esta seria a primeira e mais importante contribuição do TCC de Emir.
		Obs: Este será o principal foco do TCC e do trabalho que Emir deve desenvolver, em princípio usar a linguagem (System)Verilog para descrever o Hw do Coprocessador 0 para a nova MIPS_S, seguindo a especificação de como este coprocessador opera, conforme descrito, por exemplo nos Capítulos 3 e 5 do livro "See MIPS Run" de Dominic Sweetman. Depois da reunião Ney postou o PDF deste no nosso Googldrive. Este livro é uma referência que Ney considera melhor para a parte arquitetural do trabalho que o "MIPS R4000 Microprocessor User's Manual" de Joe Heinrich, já postado no Googledrive e usado na reunião de hoje. Claro, há muito que estudar para fazer o projeto, incluindo: (1) Definir a interface de comunicação do CP0 com o restante da organização MIPS_S; (2) Definir a nova interface externa do sistema MIPS_S+CP0 (ver item 2.5 abaixo); (3) Elaborar um método de validação do CP0 isoladamente e um método de validar o mesmo em conjunção com a CPU do MIPS_S e eventualmente periféricos externos juntados ao sistema MIPS_S_withBRAMs.
	2.3) (Hw) Modificar a estrutura do sistema MIPS_S_withBRAMs para adicionar a este regiões de memória para receber o kernel do sistema e seus dados.
		Obs: A adição do CP0 implica a definição de "modos de execução" para o software, no mínimo os modos usuário e kernel. Neste último modo é que deve se dar a execução do processo de manipulação de exceções (interrupções de periféricos, erros durante a execução de instruções, chamadas do sistema, etc.). Novamente, a experiência passada de Ney no assunto o qualifica como quem vai realizar estas modificações no Hw do sistema MIPS_S_withBRAMs, mostrando o processo todo para Emir, que vai finalmente documentar o que foi realizado no seu texto de TCC.
	2.4) (Sw) Desenvolver e testar o software de um "exception handler" para a nova versão da MIPS_S, mostrando sua correta operação no novo sistema MIPS_S_withBRAMs desenvolvido na macro-tarefa 2.3 acima, preferencialmente com um periférico que seja capaz de interromper o processador MIPS_S+CP0. Esta seria a segunda contribuição importante do TCC de Emir.
		Obs: Ney baixou o tradicional arquivo-exemplo exception.s, código fonte de um "exception handler" fornecido junto com o simulador SPIM, e adicionou o mesmo no nosso Googledrive. Emir deve estudar este código, se possível testando o mesmo no MARS. Este é o ponto de partida desta macro-tarefa.
	2.5) (Hw) Propor, desenvolver e testar uma interface de solicitação/atendimento de interrupções (um conjunto de novos pinos) para o MIPS_S+CP0. 
		Obs: Ney sugere que seja usada a especificação de pinagem (de entrada) existente no Capítulo 8 do "MIPS R4000 Microprocessor User's Manual" de Joe Heinrich. Note-se que o livro "See MIPS Run" não apresenta detalhes de pinagem de nenhuma implementação do MIPS.
		
3) Note-se que existem múltiplas interdependências entre as 5 tarefas acima, implicando que a maioria delas vai ter de ser desenvolvida em paralelo e com várias abordagens de validação sendo usadas, e.g. via testbenches de hardware, simulações em Sw etc. 

4) Outro desenvolvimento desta reunião foi o resultado de investigar as possíveis configurações de memória do simulador MARS. Como este simulador é a base que usamos hoje para gerar código para o MIPS, estas configurações são bastante relevantes. Dado que queremos um processador sobretudo para aplicações embarcadas com memória limitada, consideramos que o modelo de configuração de memória do MARS denominado "Compact, Text at Address 0" é muito útil para nossos propósitos. Depois da reunião, Ney elaborou um esboço de um novo mapa de memória, limitado a um espaço de 64Kbytes (os primeiros bytes do mapa total do MIPS, ocupando do endereço 0x00000000 a 0x0000FFFF). Neste mapa, a parte alta do mesmo (de 0x00008000 a 0x0000FFFF) é reservada para periféricos. A proposta é que este seja o novo mapa de memória para o MIPS_S+CP0. Ney vai prover o novo mapa para Emir, inicialmente como uma foto da folha manuscrita com os dados deste novo mapa, detalhando cada uma das regiões providas. A foto foi postada no Googledrive compartilhado, no sub-folder Developments.

5) Outra análise que Ney fez após a reunião foi verificar a viabilidade de prototipar a nova MIPS_S+CP0 no sistema MIPS_S_withBRAMS, modificando a sua estrutura de memória. Para tanto, a ideia é que seja possível prototipar, na plataforma disponível com a maior limitação, qual seja, a Nexys 1. As capacidades de BRAMs de algumas placas que temos são:
	5.1) Nexys-1 - FPGA XC3S200 com 12 BRAMs de 16-18Kbits - 2Kbytes usáveis
	5.2) Nexys-2 - FPGA XC3S1200E com 28 BRAMs de 16-18Kbits - 2Kbytes usáveis
	5.3) Nexys-A7 - FPGA XA7A100T com 270/135 BRAMs de 16-18Kbits/32-36Kbits - 2Kbytes usáveis nas versões de 16-18Kbits.
A proposta é então ter o novo sistema MIPS_S_withBRAMs empregando 12BRAMs (24Kbytes), suficientes para cobrir todo o mapa de memória mencionado no item 4) acima, com exceção da região denominada Extern Data e a faixa de endereços a partir de 0x00007000 do Kernel Data Segment (ver foto do manuscrito para detalhes). Este novo mapa e organização de memória da MIPS_S_withBRAMs vai ser usado como especificação para a macro-tarefa 2.3 acima.

6) Ney reorganizou um pouco os materiais do Googledrive compartilhado, para deixar o material melhor estruturado.

7) Ney deve gerar uma nova distribuição do material do MIPS_S a V3.4 e repassar a mesma para Emir e Rodrigo.

8) Ney começou a gerar uma nova versão do documento de proposta do TCC1, que eventualmente vamos re-submeter para a coordenação de TCC.


 Teste a IA diretamente nos seus apps favoritos … Use o Gemini para criar rascunhos e editar conteúdo, e tenha acesso à IA de última geração do Google com o Gemini Pro por R$ 96,99 R$ 0 durante 1 mês
Reunião de Orientação, 25/07/2025 - TCC1 Emir Bráz de Araújo Marques Júnior
Presentes: Emir, Rodrigo e Ney
Link do Googledrive para materiais do TCC do Emir: https://drive.google.com/drive/folders/1DBpFxflJj4FA5cEN1k_TOdPidxexRXPg?ths=true

1) Em reunião anterior (16/07/2025), conversamos sobre o Cap 3 e sobre o MIPS em geral e a programação do exception handler. Reunião não documentada.

2) Conjunto de assuntos a abordar hoje. I.e., itens da ata:
	2.1 - Problemas com o Mars e SPIM - OK
	2.2 - Conteúdos do Cap 3 do See MIPS Run - OK
	2.3 - Conteúdos do Cap 5 do See MIPS Run - OK
	2.4 - Vivado e o projeto HMC-Adel - OK
	2.5 - Discussão do andamento do cronograma - OK
	2.6 - Escrita do TCC - Fica para próxima reunião 
	2.7 - Papers
	2.8 - Burocracia do TCC (precisamos ajustar cronograma ou não?)
	2.9 - Dominar o processo de integração de código VHDL com Verilog - OK

3) [2.1] Ney apresentou problemas com o Mars, que não gera e não permite gerar dump das áreas de kernel (código/texto). Uma solução é usarmos o SPIM que consegue fazer dump destas áreas, mas não aceita o modelo de memória compacta que o Mars disponibiliza. Ney ainda está tentando ver como  fazer um work-around do problema antes de desistir. Soluções mais definitivas passam pela edição do fonte do Mars para permitir fazer dump das áreas de kernel. Outra possibilidade futura interessante é desenvolver uma versão do le_mars que gere memórias em Verilog e não apenas em VHDL. Também seria interessante investigar a possibilidade de fazer isto para FPGAs Altera.

4) [2.2] Sobre o Cap 3, o mais importante é a Tabela 3.1, que define todos os registradores do Cp0. Ney propõe escolher 7 destes registradores, inicialmente: SR ($12), Cause ($13), EPC ($14), Count ($9), Compare ($11), PRId ($15) e IntCtl (12.1). Precisamos dominar bem estes 7 registradores e cada um dos seus campos. Ainda temos de decidir que campos destes 7 registradores precisamos realmente usar. 

5) [2.3] O Cap 5 possui muitos conceitos importantes a dominar: "precisão" de interrupção (5.1), "entry points" de exceções (5.2-5.5), exceções aninhadas (5.6) convenções de software para o exception handler (5.7), interrupções de Hw (5.8), incluindo a construção de semáforos (5.8.3-5.8.4), inicialização do processor (5.9), emulação de instruções (5.10). Proposta para o Emir trabalhar esta semana:
	6.1) Estudar os códigos MIPS assembly do Cap 5 do See MIPS Run no contexto do texto;
	6.2) Estudar o código MIPS do arquivo exception.s no nosso drive compartilhado, procurando entender o funcionamento do exception handler proposto pelo SPIM. Inclui, ler, entender instruções e fluxo, montar e simular o código no MARS, entendendo o que ele faz.
	
6) [2.4] Ney abriu o projeto do Harvey Mudd College/Adelaide University e mostrou o esquemático completo do sistema (exceto pela memória que não está definida). 
	7.1) Observamos a estrutura de pinagem do MIPS deles, composta por três módulos hieráquicos Verilog, a Control Unit, o Datapath e o Cp0.
	7.2) Identificamos praticamente todos os sinais de interface e suas funções. 
	7.3) Ney mostrou a pinagem do Cp0, identificando alguns dos seus principais sinais de interface.
	7.4) Ney navegou pela hierarquia do Cp0, mostrando que nesta implementação existem apenas 3 registradores de controle (SR, Cause e EPC) e uma unidade de controle do Cp0.
	7.5) Ney mostrou ainda que os fontes Verilog estão todos disponíveis no projeto, abrindo alguns deles, como a definição do Cp0.
	7.6) Emir deve estudar esta implementação (incluindo os códigos fonte Verilog). A partir dela podemos criar uma interface para o nosso Cp0.
	
7) [2.5] Discutimos o andamento do cronograma:
	7.1) Ney lembrou a Emir o que significa a Tarefa 1 (Literature Review):
		1 - Buscar papers sobre o assunto do TCC;
		2 - Ler o abstract de cada paper coletado. Com base no abstract decidir por ou selecionar o paper como parte da revisão ou descartar o paper, por não fazer sentido para o trabalho;
		3 - Ler cada paper selecionado com atenção e resumir o mesmo (depois este resumo servirá de base para a escrita do Cap de Estado da Arte do TCC).Para cada paper lido, o resumo dele deve dizer:
			3.1 - O que o paper propõe, resumidamente;
			3.2 - Como o trabalho difere do TCC em pauta;
			3.3 - Como a abordagem é mais limitada ou mais ampla que o TCC em pauta;
			3.4 - O que o paper não faz e que eu estou propondo fazer.
	7.2) Trabalhos de Emir a partir de hoje sobre a Tarefa 1 (Literature Review):
		1 - Emir resume os 5 papers que ele já leu (ou vai reler/terminar de ler) - Papers: 2008 de Pinckney (hmc MIPS2000), de 2016/2017 de Harris et al. (MIPSFpga), de 2017 dos russos (MIPSFpga+) e de 2022 de moscovitas (SchoolMIPS)
		2 - Ney faz upload dos 5 novos papers que coletou no nosso drive compartilhado e Emir lê os 5 novos papers
		3 - Emir refaz a pesquisa que Ney já fez na IA do Google (usando o string de pesquisa "") e vê que novos papers relevantes aparecem nesta pesquisa. Achando novos papers, Emir aplica o processo descrito em 7.1)-3 acima e coloca os papers relevantes no nosso drive compartilhado.
		
8) [2.6] Este item de pauta será tema da próxima reunião, a realizarmos dia 1ro/08/2025. Nele vamos teantar estabelecer um esqueleto em dois níveis para estruturar a escrita do TCC de Emir (O esquele comportará a definição de Capítulos e Seções deste para o TCC completo. Mais tarde começamos a encher este esqueleto com carne, ou melhor, com texto). Até semana que vem, Ney vai analisar o atual template que o texto do Emir no Overleaf apresenta e ver se o mesmo está compatível com o template LaTeX da UFSC para TCCs. 

9) [2.7] - Ver acima o item 7.2 durante a discussão do cronograma do TCC...

10) [2.8] Pela análise do cronograma administrativo de TCC2, decidimos q ue a data de entrega do volume para a banca é no meio da semana 20 do nosso cronograma, até o dia 19/11/2025. Emir envia os nomes do Orientador e do Co-orientador no chat ainda hoje. Dia 11/11/2025 é o prazo final para Ney e Rodrigo indicarem a banca, bem como o dia/hora/local da defesa do TCC2. Links para material do cronograma administrativo de TCC2:
	10.1) Modelo LaTeX de monografia: https://pt.overleaf.com/latex/templates/template-trabalho-de-conclusao-de-curso-ufsc-a4/fptzhfwsndsz
	10.2) Capa/Folha de Rosto/Assinaturas: 
https://www.overleaf.com/project/63ff76bd2c28d2ac4099e6b7
	10.3) Modelo LaTeX de artigo:
https://www.overleaf.com/project/63ff75e38f5f4d61974d3cfe
	10.4) Planilha com datas de TCC agendadas
https://docs.google.com/spreadsheets/d/168BKsE6QBw2EHMTwTlz03WfQjJX_KWONqO2hPP2rzD8/edit?gid=1274106563#gid=1274106563
	10.5) Procedimento de validar o TCC publicado
https://enc.ufsc.br/aproveitamento-de-artigo-publicado/
	10.6) Link para o Qualis Periódicos:
https://sucupira-legado.capes.gov.br/sucupira/public/consultas/coleta/veiculoPublicacaoQualis/listaConsultaGeralPeriodicos.xhtml
	10.7) Link para o Qualis Eventos:
https://www.gov.br/capes/pt-br/centrais-de-conteudo/documentos/avaliacao/09012022_RELATORIOQUALISEVENTOS20172020COMPUTACAO.PDF 

11) [2.9] Emir deve se familiarizar com a integração VHDL/Verilog, em particular no Vivado. Ney fez uma pequena pesquisa na IA do Google pela expressão "How to integrate VHDL and Verilog modules in Vivado" e achou material bem útil.

Teste a IA diretamente nos seus apps favoritos … Use o Gemini para criar rascunhos e editar conteúdo, e tenha acesso à IA de última geração do Google com o Gemini Pro por R$ 96,99 R$ 0 durante 1 mês
Reunião de Orientação, 04/08/2025 - TCC2 Emir Bráz de Araújo Marques Júnior
Presentes: Emir, Rodrigo e Ney
Link do Googledrive para materiais do TCC do Emir: https://drive.google.com/drive/folders/1DBpFxflJj4FA5cEN1k_TOdPidxexRXPg?ths=true

1) Conjunto de assuntos a abordar hoje, i.e. itens da ata:
	1.1 - Discussão do andamento do cronograma - OK
	1.2 - Problemas com o Mars e SPIM (Ney, Eduardo Zambotto) - OK
	1.3 - Conteúdos do Cap 5 do See MIPS Run - OK
	1.4 - Vivado e o projeto HMC-UAdel (Emir) - OK
	1.5 - Escrita do TCC (Ney, template) - OK
	1.6 - Discussão de papers e papers novos coletados (Emir) - OK
	1.7 - Prática de Emir com VHDL com Verilog (Rodrigo) - OK

2) [1.1] - Estamos iniciando a semana 5. 
	Estão ou deveriam estar em andamento no momento as tarefas 1-5 e as tarefas 8 e 12.
	- Tarefa 1 - Bastante bibliografia já coletada, seria bem ter mais.
	- Tarefa 2 - Em tese assuntos (Caps 3 e 5 do See MIPS Run) dominados, agora Emir começa a escrever texto sobre como funciona a 		manipulação de exceções no MIPS (os mecanismos deste processo). A escrita final desta parte do TCC2 deve estar pronta em 9 semanas, na semana 13.
	- Tarefa 3 - Está atrasada, Ney deve tocar ela esta semana. Consiste em selecionar um número mínimo de instruções que precisamos, e fazer uma implementação incial delas. Enquanto isto, Emir tem que dominar o MIPS_S, seja a nível de sua organização de Hw, seja a nível de sua programação e sua interação com memórias disponíveis. Dos 3 tutoriais (Simulação com Vivado, Prototipação com Vivado e Simulação de hardware de um programa executando no MIPS_S), Emir realizou o primeiro destes.
	- Tarefa 4 - Está 2 semanas atrasada, Ney toca ela esta semana.
	- Tarefa 5 - Está 1 semana atrasada, Ney toca ela esta semana.
	- Tarefa 8 - Estamos quase prontos para usar nova versão do MARS do Eduardo Zambotto, para gerar dumps de memória para o Kernel. Depois disto, Ney faz a adaptação.
	- Tarefa 12 - Primeira grande tarefa de implementação que cabe a Emir, deve começar a criar uma casca de um Cp0 em Verilog e integrá-la com a Control Unit e o Datapath da MIPS_S_Prt.

3) [1.2] Eduardo Zambotto trabalhando numa versão do MARS para fazer dump das áreas de texto e dados do kernel. Se tudo der certo, a nova versão estará pronto até o fim desta semana. 
Atualização: em 07/08/2025  já temos uma versão do Mars capaz de gerar os dumps do texto e dos dados do kernel!

4) [1.3] Sobre o Cap 5, Rodrigo levantou a questão de se código de usuário pode ou não ter acesso ao Cp0 (para escrita? e/ou leitura?). Temos que investigar esta questão e talvez isto justifique implementar as instruções de trap para ir ao kernel e voltar depois de fazer certas coisas, tais como habilitar e/ou desabilitar uma ou mais interrupções.

5) [1.4] Emir ainda deve rodar o Vivado sobre a implementação do HMC-UAdel.

6) [1.5] Ney adapta o template do TCC2 para Emir começar a escrever. Tarefa para Emir: Criar uma proposta de esqueleto do texto do TCC em dois níveis:
	6.1) Capítulos (quantidade de capítulos e um nome para cada um destes).
	6.2) Conjunto de Seções para cada Capítulo (quantidade de seções em cada capítulo e um nome para cada um destas).

7) [1.6] Emir está fazendo os resumos dos papers já lidos. Depois vai empreender o processo de procurar mais artigos.

8) [1.7] Rodrigo e Emir trabalhando em tutoriais relacionados a Verilog:
	8.1 - Emir precisa de tutoriais de como integrar módulos Verilog e VHDL.
	8.2 - Tutoriais gerais sobre Verilog são bons para o Mateus Sodré, que precisa aprender Verilog.
    Teste a IA diretamente nos seus apps favoritos … Use o Gemini para criar rascunhos e editar conteúdo, e tenha acesso à IA de última geração do Google com o Gemini Pro por R$ 96,99 R$ 0 durante 1 mês
Reunião de Orientação, 14/08/2025 - TCC2 Emir Bráz de Araújo Marques Júnior
Presentes: Emir, Rodrigo e Ney
Link do Googledrive para materiais do TCC do Emir: https://drive.google.com/drive/folders/1DBpFxflJj4FA5cEN1k_TOdPidxexRXPg?ths=true

1) Conjunto de assuntos a abordar hoje, i.e. itens da ata:
	1.1 - Discussão do andamento do cronograma - OK
	1.2 - Problemas com o Mars e SPIM (Ney, Eduardo Zambotto) - OK
	1.3 - Conteúdos do Cap 5 do See MIPS Run - OK
	1.4 - Vivado e o projeto HMC-UAdel (Emir) - OK
	1.5 - Escrita do TCC (Ney, template) - OK
	1.6 - Discussão de papers e papers novos coletados (Emir) - OK
	1.7 - Prática de Emir com VHDL com Verilog (Rodrigo) - OK

2) [1.1] - Estamos iniciando a semana 5. 
	Estão ou deveriam estar em andamento no momento as tarefas 1-5 e as tarefas 8 e 12.
	- Tarefa 1 - Bastante bibliografia já coletada, seria bem ter mais.
	- Tarefa 2 - Em tese assuntos (Caps 3 e 5 do See MIPS Run) dominados, agora Emir começa a escrever texto sobre como funciona a 		manipulação de exceções no MIPS (os mecanismos deste processo). A escrita final desta parte do TCC2 deve estar pronta em 9 semanas, na semana 13.
	- Tarefa 3 - Está atrasada, Ney deve tocar ela esta semana. Consiste em selecionar um número mínimo de instruções que precisamos, e fazer uma implementação incial delas. Enquanto isto, Emir tem que dominar o MIPS_S, seja a nível de sua organização de Hw, seja a nível de sua programação e sua interação com memórias disponíveis. Dos 3 tutoriais (Simulação com Vivado, Prototipação com Vivado e Simulação de hardware de um programa executando no MIPS_S), Emir realizou o primeiro destes.
	- Tarefa 4 - Está 2 semanas atrasada, Ney toca ela esta semana.
	- Tarefa 5 - Está 1 semana atrasada, Ney toca ela esta semana.
	- Tarefa 8 - Estamos quase prontos para usar nova versão do MARS do Eduardo Zambotto, para gerar dumps de memória para o Kernel. Depois disto, Ney faz a adaptação.
	- Tarefa 12 - Primeira grande tarefa de implementação que cabe a Emir, deve começar a criar uma casca de um Cp0 em Verilog e integrá-la com a Control Unit e o Datapath da MIPS_S_Prt.

3) [1.2] Eduardo Zambotto trabalhando numa versão do MARS para fazer dump das áreas de texto e dados do kernel. Se tudo der certo, a nova versão estará pronto até o fim desta semana. 
Atualização: em 07/08/2025  já temos uma versão do Mars capaz de gerar os dumps do texto e dos dados do kernel!

4) [1.3] Sobre o Cap 5, Rodrigo levantou a questão de se código de usuário pode ou não ter acesso ao Cp0 (para escrita? e/ou leitura?). Temos que investigar esta questão e talvez isto justifique implementar as instruções de trap para ir ao kernel e voltar depois de fazer certas coisas, tais como habilitar e/ou desabilitar uma ou mais interrupções.

5) [1.4] Emir ainda deve rodar o Vivado sobre a implementação do HMC-UAdel.

6) [1.5] Ney adapta o template do TCC2 para Emir começar a escrever. Tarefa para Emir: Criar uma proposta de esqueleto do texto do TCC em dois níveis:
	6.1) Capítulos (quantidade de capítulos e um nome para cada um destes).
	6.2) Conjunto de Seções para cada Capítulo (quantidade de seções em cada capítulo e um nome para cada um destas).

7) [1.6] Emir está fazendo os resumos dos papers já lidos. Depois vai empreender o processo de procurar mais artigos.

8) [1.7] Rodrigo e Emir trabalhando em tutoriais relacionados a Verilog:
	8.1 - Emir precisa de tutoriais de como integrar módulos Verilog e VHDL.
	8.2 - Tutoriais gerais sobre Verilog são bons para o Mateus Sodré, que precisa aprender Verilog.
    Teste a IA diretamente nos seus apps favoritos … Use o Gemini para criar rascunhos e editar conteúdo, e tenha acesso à IA de última geração do Google com o Gemini Pro por R$ 96,99 R$ 0 durante 1 mês
Reunião de Orientação, 21/08/2025 - TCC2 Emir Bráz de Araújo Marques Júnior
Presentes: Emir, Rodrigo e Ney
Link do Googledrive para materiais do TCC do Emir: https://drive.google.com/drive/folders/1DBpFxflJj4FA5cEN1k_TOdPidxexRXPg?ths=true

1) Conjunto de assuntos a abordar hoje, i.e. itens da ata:
	1.1 - Escrita do TCC (Ney, template) - OK
	1.2 - Discussão do andamento do cronograma - 
	1.3 - Vivado e o projeto HMC-UAdel (Emir) - 
	1.4 - Discussão de papers e papers novos coletados (Emir) - 

2) [1.1] - Ney concluiu o template em inglês e compartilhou com Emir e Rodrigo.
	Urgente: Emir deve começar a colocar texto no TCC, em particular os resumos dos artigos lidos/revisados.
	Urgente: Tínhamos acertado que Emir elaboraria um esqueleto do TCC (capítulos e seções destes), onde este se encontram. O template do Overleaf deve refletir a proposta de esqueleto.
	2.1) Na reunião de hoje, trabalhamos um bom tempo para descrever como elaborar  esqueleto (Capítulos e Seções) para o TCC. Desenvolvemos uma proposta em 2 níveis para o Capítulo 1
	2.2) Elaboramos uma parte do esqueleto com 8 capítulos - Emir deve propor um conjunto de seções para  os capítulos 2-8;
	2.3) Ney mostrou uma parte da Proposta de Tese do Angelo Dal Zotto, orientando de Fernando Moraes no PPGCC da PUCRS, apresentada e aprovada em 27/02/2024 (Ney foi membro da banca). Em particular examinamos o Cap 2 (Background Knowledge) e o Cap 3 (State of the Art) para Emir ter uma ideia de como estes assuntos são após estruturados. Ney disponibiliza o texto da Proposta para Rodrigo e Emir.
	
3) [1.2] - Estamos no final da semana 7.
	Tarefas concluídas antes ou ao final da semana 7: 3, 4, 5, 8
	Tarefas em andamento durante a semana 8 ou após: 1, 2, 6, 7, 9, 12
	- Tarefa 1 (Revisão do Estado da Arte) - Bastante bibliografia já coletada, seria bem ter mais.
	- Tarefa 2 (Revisão dos mecanismos de tratamento de exceção do MIPS e definição do mapa de memória do MIPS_S_Cp0) - Em tese assuntos (Caps 3 e 5 do See MIPS Run) dominados, agora Emir começa a escrever texto sobre como funciona a manipulação de exceções no MIPS (os mecanismos deste processo). A escrita final desta parte do TCC2 deve estar pronta em 6 semanas, na semana 13. Dado o que discutimos, isto seria o conteúdo a ser colocado no Capítulo 2 (Background Knowledge). Ney deve começar a adaptar o ambiente de software le_mars para lidar com a separação de memórias de usuário e kernel e elaborar um exemplo de aplicação a usar para testar e validar a nova organização de memórias.
	- Tarefa 3 (Extensão do conjunto de instruções do MIPS_S) - Está atrasada, Ney deve tocar ela esta semana, pois as duas primeiras semanas de aula foram bem cheias. Consiste em selecionar um número mínimo de instruções que precisamos, e fazer uma implementação incial delas. Enquanto isto, Emir tem que dominar o MIPS_S, seja a nível de sua organização de Hw, seja a nível de sua programação e sua interação com memórias disponíveis. Dos 3 tutoriais (Simulação com Vivado, Prototipação com Vivado e Simulação de hardware de um programa executando no MIPS_S), Emir realizou o primeiro destes.
	- Tarefa 4 (Concluir proposta de instruções a implementar) - Está 3 semanas atrasada, Ney toca ela esta semana.
	- Tarefa 5 (Interface e registradores iniciais para o CP0) - Está 3 semanas atrasada, Rodrigo e Emir vão tocar ela ainda esta semana.
	- Tarefa 8 - Estamos prontos para usar nova versão do MARS do Eduardo Zambotto, para gerar dumps de memória para o Kernel. Adaptação será feita por Ney.
	- Tarefa 12 - Primeira grande tarefa de implementação que cabe a Emir, deve começar a criar uma casca de um Cp0 em Verilog e integrá-la com a Control Unit e o Datapath da MIPS_S_Prt.

4) [1.3] Emir continua trabalhando em entender como funciona o MIPS R2000 do Harvey-Mudd College. Importante, por exemplo: descobrir o que é e para que serve o sinal "swc" gerado pelo CP0 do HMudd  e mandado para fora do MIPS.

5) [1.4] Não deu tempo de discutir este tópico, fica para a semana que vem.
Teste a IA diretamente nos seus apps favoritos … Use o Gemini para criar rascunhos e editar conteúdo, e tenha acesso à IA de última geração do Google com o Gemini Pro por R$ 96,99 R$ 0 durante 1 mês
Reunião de Orientação, 27/09/2025 - TCC2 Emir Bráz de Araújo Marques Júnior
Presentes: Emir e Ney
Link do Googledrive para materiais do TCC do Emir: https://drive.google.com/drive/folders/1DBpFxflJj4FA5cEN1k_TOdPidxexRXPg?ths=true

1) Emir está com o hardware do CP0 em bom estado de andamento, já temos os 6 registradores de controle já implementados: Status, Cause, EPC, Count, Compare e IntCtl. Com o que discutimos hoje, Emir tem ideia dos ajustes a realizar no hardware, que ele vai executar. Ver alguns detalhes nos itens a seguir.

2) Descobrimos que o sinal de entrada "interrupts [7:0]" do CP0, que tb é entrada do processador completo (MIPS_S+Cp0), deve ser alterado para "interrupts [7:4]". Porquê? Pelo motivo que estudamos e descobrimos que: 
	2.1) A interrupções de 0 e 1 são reservadas para interrupções geradas por instruções executadas no MIPS_S (tipicamente traps condicionais, que não vamos implementar). 
	2.2) Além disto, uma interrupção (a 2) foi reservada para uma característica que não vamos usar ou implementar agora, os contadores de desempenho. Talvez no futuros tenhamos que acrescentar um pino interrupts[2], se tais contadores forem criados externamente ao conjunto MIPS_S+Cp0.
	2.3) Finalmente a interrupção 3, decidimos, fica reservada para ser gerada pelo par de registradores Count & Compare e seu comparador , cuja saída será interna ao CP0 e equivalente ao pino "interrupts [3]". Assim, os pinos "interrupts [7:4]" são pinos reais de entrada e serão conectados a periféricos externos reais, ou a um futuro controlador de interrupções, que gerenciará a ativação destes 4 pinos de entrada do conjunto MIPS_S+Cp0.

3) Outra coisa que estudamos e decidimos hoje é que a implementação do registrador IntCtl (que será de fato a constante de 32 bits 0x68000020) implica que temos que dar suporte, nas instruções mtc0 e mfc0, a não apenas versões destas com dois operandos, mas a versões com 3 operandos, pois no MIPS32 existe a possibilidade de termos até 256 registradores de controle dentro do Cp0.
	3.1) Os registradores Status (12), Cause (13), EPC (14), Count (9), Compare (11) possuem números entre 0-31, mas o IntCtl é especificado como o registrador (12.1), onde o campo 1 é um campo de 3 bits que estende o campo de 5 bits que contém o endereço base do registrador.
	3.2) Assim, os sinais de interface do Cp0 que contêm os endereços de registradores dele passam de "input [4:0] cp0_readaddress, cp0_writeaddress [4:0]," para "input [7:0] cp0_readaddress, cp0_writeaddress [7:0],". Aqui, os antigos 5 bits [4:0] passam a ser os 5 bits [7:3], e o campo de 3 bits corresponderá aos bits [2:0] do sinal de endereço. No caso de registradores que têm um valor inteiro entre 0-31, os três bits (possivelmente não especificados) valem "000". Por exemplo, o registrador Status possui endereço 12.0 ou, em binário, 01100000. Para o IntCtl (12.1) no entanto, o endereço é 01100001 em binário.
	
4) Ney deu uma olhada na forma de codificação Verilog e fez algumas recomendações ao Emir para organizar um pouco melhor a nomenclatura das estruturas. Seguem algumas regras que Ney costuma usar para escrever código para hardware: 
	4.1) O nome de um registrador deve ser atribuído ao nome dos vetor de fios de saída deste registrador. Assim, por exemplo, o nome Status é o nome dos 32 bits de saída do registrador de mesmo nome. Isto facilita as referências entre manuais e monografias e o código fonte Verilog/VHDL. Emir deve renomear os sinais do seu código para  seguir esta regra. Assim, por exemplo, o sinal que hoje se chama "output reg [31:0] statusreg" deve mudar para "output reg [31:0] status". 
	4.2) Sinais que são endereços ou dados devem ter um sufixo "_add" ou "_addr" para endereços e "_data" para dados. Isto facilita identificar os barramentos que transportam os diferentes tipos de informação...
	
5) Emir começou a codificar Sw (handlers de exceções e software de testes, ver o projeto GitHub nos folders abaixo do folder Sw). Emir pediu para Ney e Rodrigo olharem o que já está feito. Ney considera que agora devemos dar uma boa ênfase na escrita de software (codificação do kernel e os códigos de testes que o usuário pode usar para trabalhar com exceções...).
Teste a IA diretamente nos seus apps favoritos … Use o Gemini para criar rascunhos e editar conteúdo, e tenha acesso à IA de última geração do Google com o Gemini Pro por R$ 96,99 R$ 0 durante 1 mês
Conversas de Orientação, 29/09/2025 a 02/10/2025 (WhatsApp) - TCC2 Emir Bráz de Araújo Marques Júnior
Link do Googledrive para materiais do TCC do Emir: https://drive.google.com/drive/folders/1DBpFxflJj4FA5cEN1k_TOdPidxexRXPg?ths=true

1-Ney) Bom dia, Emir. Dei uma olhada nos códigos que começaste a escrever, mas estão muito no início e muito incompletos. Temos que avançar muito neste software. Algumas questões que já dá para mencionar:
	1.1) Dado o modelo de memória que adotamos (Ver arquivo MIPS_S_Embedded_MemoryMap, elaborado por Ney e enviado a todos em 25/09/2025), temos:
		1.1.1) Na primeira linha do teu arquivo exception_handler.asm consta: ".ktext 0x80000180". Isto não está de acordo com o modelo de memória que estamos usando, que é o modelo de memória compacto, conforme o mapa de memória que mandei aqui no grupo, na quinta-feira passada, veja a imagem anexada aqui. O endereço de início do exception handler (no modelo compacto do MARS) é 0x00004180, lembra?
		1.1.2) Minha sugestão é começares por escrever o código do atendimento da interrupção do par Count-Compare, pois este Hw ja está,  em tese pronto. Faz um programa de teste a nível de usuário que leia o valor do Count, some uns 1.000 ou 10.000 ao valor lido, escreva no Compare, e depois entra em um laço esperando que a interrupção ocorra. Depois, escreve o código de atendimento da interrupção no nível do kernel. Lembrando que qdo o código do nível do usuário acontecer, tens de garantir que as interrupções estão habilitadas. Isto requer que o código inicial do kernel,  executado ao ligar/ressetar o processador, tenha executado, deixando as interrupções habilitadas.

2-Emir) 01/10/2025 - Boa noite, professores. Terminei agora de fazer todas as atualizações solicitadas, amanhã mando um retorno com os tests efetuados (handler e testbench) e o um teste no VIVADO do hw. Tudo já atualizado no github.

3-Ney) 02/10/2025 - Nesta reunião, Ney e Emir fizeram uma  reunião onde redefiniram a estrutura da interface do Cp0. O texto abaixo contém a revisão da interface construída nesta reunião.
------------------------------ Revisão da interface do Cp0 ---
// Versão atual do Emir
module coprocessor0(
  input	clk, reset,
  input	[7:4] interrupts,		// IRQ externas colocar de 7 a 4
  input         cop0write,		// pulso MTC0
  input   [7:0] cp0_read_addr,	// mudar para 8 bits para sel
  input   [7:0] cp0_write_addr, 
  input   [31:0] writecop0,		// dado vindo da ULA
  input   [31:0] pc,
  input         syscall,
  input         ri,				// reserved instruction
  // entradas futuras:
  input         overflow,
  input         divzero,
  input         eret,			// return from exception
  input         activeexception,
  output reg [31:0] cop0readdata,
  output        pendingexception
);

------------------------------ Nova interface do Cp0 ---
// Proposta de alteração de nomes para os sinais da interface do Cp0 - Ney Calazans
module Cp0( 					// Name of the MIPS_S_Cp0 highest level module
  // Cp0 external pins 
  input	clk, reset,				// Main control signals: clock (Cp0 is sensitive to its rising edge) and active-high reset ) 
  input	[7:4] interrupts,		// There are only four external IRQ pins [7:4], The four interrupts [3:0} are internal to the MIPS_S_Cp0

  // Read/Write data interface between CPU and Cp0
  input	Cp0_wren,				// Write enable control
  input	[7:0]  Cp0_wraddr,		// Cp0 register write address, in the form [7:3].[2:0] Example: the address of a register 12.4 would be 01100 100
  input	[31:0] Cp0_wrdata,		// Incoming data to write to some CP0 register, typically coming from the MIPS_S CPU ALU
  input	[7:0]  Cp0_rdaddr,		// Cp0 register read  address, in the form [7:3].[2:0] Example: the address of a register 12.4 would be 01100 100 
  output reg [31:0] Cp0_rddata,	// Output data, typically the contents of some Cp0 register requested by the MIPS_S CPU
  //  input	[31:0] Cp0_EPC,		// Incoming data from the MIPS_S CPU, typically coming from the MIPS_S PC Register. Question: Do we need it?
								// This would only be useful to store the EPC value, right?
  // other signals
  //input	syscall,			// Is this a flag indicating a syscall has been executed?
  //input	ri,					// Is this a flag indicating a non-implemented instruction execution has been attempted? (Reserved Instruction?)
								// Future inputs???
  //input	overflow,			// Would this be an indication that an arithmetic overflow occurred? Do we need it?
  //input divzero,				// Would this be an indication that an attempt to divide an integer by zero has occurred? Do we need it?

  //input	eret,				// Would this be an indication that an exception return instruction has been executed? Do we need it?
  //input	activeexception,	// Would this be an indication that an exception has occurred? Do we need it?

  output	pendingexception	// An output stating that there is at least one exception pending treatment, right?
);
------------------------------ Fim ---
Teste a IA diretamente nos seus apps favoritos … Use o Gemini para criar rascunhos e editar conteúdo, e tenha acesso à IA de última geração do Google com o Gemini Pro por R$ 96,99 R$ 0 durante 1 mês
Conversas de Orientação, 03/10/2025 (WhatsApp) - TCC2 Emir Bráz de Araújo Marques Júnior
Link do Googledrive para materiais do TCC do Emir: https://drive.google.com/drive/folders/1DBpFxflJj4FA5cEN1k_TOdPidxexRXPg?ths=true

1-Ney) Oi Pessoal. Desde ontem estou com o problema de como a CPU informa o periférico que atendeu (ou está atendendo) uma interrupção solicitada por este periférico. Descobri várias possibilidades:
	1.1) A MIPS CPU notifies a peripheral that an interrupt has been acknowledged by the peripheral's corresponding interrupt controller sending a signal, often an interrupt acknowledge signal (like PIACK) or a specific address on the Program Address Bus, which the peripheral then uses to clear its interrupt flag. This acknowledgement is part of the handshake between the CPU and the interrupt controller to service the hardware request, allowing the peripheral to reset its interrupt flag and prepare for future requests. 
	Steps in Interrupt Acknowledgment
		a) Interrupt Request: A peripheral signals a need for CPU attention by sending an interrupt request (IRQ) through its dedicated line to the interrupt controller. 
		b) CPU Acknowledgment: The CPU, after completing the current instruction, acknowledges the interrupt. This action involves setting an interrupt acknowledge bit in the interrupt controller or by sending a specific interrupt priority level on the Program Address Bus (PAB) to the interrupt controller.`
		c) Peripheral Recognition: The peripheral's interrupt controller uses the information provided by the CPU (like the priority level) to identify the source of the interrupt. 
		d) Acknowledgement Signal: The interrupt controller then signals the peripheral that the CPU has acknowledged the interrupt. This signal can take several forms, such as a dedicated interrupt acknowledge signal (PIACK).
		e) Interrupt Flag Clearing: Upon receiving this acknowledgement signal, the peripheral can then clear its specific interrupt flag, indicating that the event that triggered the interrupt has been handled by the CPU. 
		f) MIPS-Specific Details Cause Register: The MIPS CPU has a Cause register (register 13) that records the type of pending interrupt. After an interrupt, the CPU will populate this register before jumping to the Interrupt Service Routine (ISR).
		g) Status Register: The Status register (register 12) contains bits for interrupt masking and enabling, which the MIPS CPU uses to control whether interrupts are accepted.
	1.2) Em resumo, tem duas formas usadas no MIPS: 
		a) Criar uma sinal de Interrupt acknowledge (saída do MIPS_S_Cp0) ou 
		b) Escrever em algum endereço reservado para se comunicar com o periférico (Memory-mapped I/O). 
		c) Ou combinar ambos... 
	Acho melhor usarmos a opção b), que é mais genérica e não implica pinos adicionais no Hw. Devemos selecionar um endereço (no mínimo) para cada interrupção.
    Teste a IA diretamente nos seus apps favoritos … Use o Gemini para criar rascunhos e editar conteúdo, e tenha acesso à IA de última geração do Google com o Gemini Pro por R$ 96,99 R$ 0 durante 1 mês
Conversas de Orientação, 09/10/2025 (WhatsApp) - TCC2 Emir Bráz de Araújo Marques Júnior
Link do Googledrive para materiais do TCC do Emir: https://drive.google.com/drive/folders/1DBpFxflJj4FA5cEN1k_TOdPidxexRXPg?ths=true

1-Ney) Boa tarde @Emir e @Rodrigo. Esta semana dediquei um tempo para estudar como operacionalizar o comportamento de Hw/Sw do MIPS_S_Cp0. Basicamente, resolvi começar a implementar um software de boot para o Processador, que obviamente deve rodar no modo kernel. Estudei um pouco o assunto de inicialização, que no nosso caso vai ser mais simples que no caso geral, pois não temos uma flash de boot (BIOS), nem SO, nem caches. Vejamos a proposta?

2-Ney) A IA do Google diz: The MIPS processor startup code is a small piece of assembly code that runs immediately after a reset, typically located at a fixed address like 0x1FC00000, to 
	(1) initialize system resources,
	(2) load a larger C-based "C" application into RAM, and then 
	(3) branch to the main C entry point.
Key initialization steps include 
	(1.1) setting up the Coprocessor 0 (CP0) status register,
	(1.2) clearing memory (like BSS), and 
	(1.3) potentially copying the operating system or application code from non-volatile memory (like Flash) into RAM before execution begins.

3-Ney) Bom, para nós interessa apenas o passo 1.1 acima, já que os demais itens (1.x, com x = 2, 3) não existem (clearing memory não é necessário, copiar OS/app não vai ser necessário, pois nossa app vai ser carregada em memória durante a síntese do Hw). Os passos 2 e 3 mais acima tb não são necessários no nosso caso.
Teste a IA diretamente nos seus apps favoritos … Use o Gemini para criar rascunhos e editar conteúdo, e tenha acesso à IA de última geração do Google com o Gemini Pro por R$ 96,99 R$ 0 durante 1 mês
Conversas de Orientação, 17/10/2025 (WhatsApp) - TCC2 Emir Bráz de Araújo Marques Júnior
Link do Googledrive para materiais do TCC do Emir: https://drive.google.com/drive/folders/1DBpFxflJj4FA5cEN1k_TOdPidxexRXPg?ths=true

1-Ney) Olá Pessoal. Lembram que no modelo compacto do MIPS, que estamos usando, o kernel começa no endereço 0x00004000 e que o exception handler começa no endereço 0x00004180? Pois é, então, enquanto Emir está escrevendo partes do exception handler, eu vou começar a escrever o código de boot, a partir do endereço .kernel text (0x00004000). Se este código precisar mais do que o espaço existente entre 0x4000 e 0x4180, pulo por cima do exception handler e continuo depois dele.

2-Ney) Na reunião de ontem, Emir e Ney fecharam uma primeira versão da interface do Cp0, que contém além dos tradicionais sinais de controle 
	(1) (clock, reset) uma 
	(2) interface de leitura de registradores Cp0 pela CPU (sinais Cp0_read_addr e Cp0_read_data), uma
	(3) interface de escrita de registradores Cp0 pela CPU (sinais Cp0_write_addr, Cp0_write_en, Cp0_write_data), uma 
	(4) entrada valor do PC (sinal i_address, para salvar o valor Exception PC no  EPC. Pensando bem agora, creio que este sinal pode ser dispensado, e usamos a interface de escrita de registradores padrão mencionada acima para realizar o processo de salvamento no EPC. Vou multiplexar o barramento de escrita no Cp0 para usar ou a saída da ULA ou a saída do PC. @Emir remove o sinal i_address da interface do Cp0).
Depois, removemos da interface do Cp0 os sinais que qualificavam o tipo de exceção (sinais overflow, eret, etc.), achamos no momento que eles são desnecessários. Os últimos sinais são
	(5) a entrada do Cp0 activeexception (CPU notifica Cp0 que tem uma exceção acontecendo), e um sinal de saída do Cp0, pendingexception, útil por exemplo para o Cp0 notificar que uma interrupção aconteceu ou está acontecendo.

3-Ney) Acertamos na mesma reunião que Emir vai ajustar a interface para as definições acima e avisar o Ney quando terminar isto. A partir daí Ney começa a implementar o hardware que implementa a execução das instruções a que vamos dar suporte nesta primeira versão do Cp0: MFC0, MTC0, ERET, SYSCALL.

4-Ney) Depois, Ney escreve o código de boot para colocar CPU e Cp0 no ponto certo para começar a executar programas de usuário.

5-Ney) @Emir fica responsável no momento por duas partes: implementação da interrupção (Hw e Sw) relacionada ao par de registradores Count e Compare e desenvolvimento da máquina de estados de controle do Cp0 (tem que trabalhar junto com @Ney nisto...)

6-Ney) Para o @Rodrigo ficou a tarefa de desenvolver Sw e Hw de interrupções de dispositivos externos, criando um exemplo de periférico simples (e.g. entrada e saída serial com capacidade de interromper o MIPS_S_Cp0).
Teste a IA diretamente nos seus apps favoritos … Use o Gemini para criar rascunhos e editar conteúdo, e tenha acesso à IA de última geração do Google com o Gemini Pro por R$ 96,99 R$ 0 durante 1 mês
Conversas de Orientação, 25/11/2025 (WhatsApp) - TCC2 Emir Bráz de Araújo Marques Júnior
Link do Googledrive para materiais do TCC do Emir: https://drive.google.com/drive/folders/1DBpFxflJj4FA5cEN1k_TOdPidxexRXPg?ths=true

1-Ney) Boa tarde Emir! Voltei de minha viagem. Minha ideia, depois de nossa última conversa, é que continuemos a trabalhar no teu TCC normalmente, com as reuniões regulares mantidas nas quintas-feiras ás 16h30. Fica bom este esquema para ti também?

2-Ney) Consegui trabalhar um pouco no software para gerar diversos módulos de memória, e já consigo isto para a memória de dados (ou seja, já ´podemos gerar os segmentos de user data  segment, kernel data segment, etc.). Ainda tenho que trabalhar o software para podermos gerar múltiplos módulos de memória para instruções, de tal forma a podermos ter uma geração de memórias adequado para lidar com os segmentos user text, kernel text, etc, mas agora já peguei o jeito e deve ser rápido generalizar o le_mars para nossas finalidades...
Teste a IA diretamente nos seus apps favoritos … Use o Gemini para criar rascunhos e editar conteúdo, e tenha acesso à IA de última geração do Google com o Gemini Pro por R$ 96,99 R$ 0 durante 1 mês
Reunião de Orientação, 05/03/2026 - TCC2 Emir Bráz de Araújo Marques Júnior
Presentes: Emir, Rodrigo e Ney
Link do Googledrive para materiais do TCC do Emir: https://drive.google.com/drive/folders/1DBpFxflJj4FA5cEN1k_TOdPidxexRXPg?ths=true
Link do Github para projeto do TCC do Emir: https://github.com/ufsctasks/thesis

1) Acertamos que as nossas reuniões serão nas sextas-feiras às 14h realizadas normalmente online. Ney não pode dia 13/03 (tem banca de doutorado), então na semana que vem ficamos de nos reunir na quarta-feira às 14h; proposta é fazermos reunião presencial em Araranguá.

2) Esta foi uma reunião de retorno ao trabalho pós-férias. Ney ontem gerou uma atualização das atas de reuniões a partir dos conteúdos do grupo de WhatsApp, resumindo os trabalhos a realizar a partir deste semestre. Ficamos assim:
	2.1) Emir
		2.1.1) Escreve código do software para controlar os módulos Count/Compare do Cp0, realizando a função que deles se espera;
		2.1.2) Mostre que o Cp0 como implementado hoje funciona via simulação (escrever testbench e simular o sistema, o testbench deve agir como o MIPS agiria, gerando entradas para o Cp0 e processando as saídas deste);
	2.2) Ney
		2.2.1) Gera uma versão do software le_mars que seja capaz de gerar múltiplos módulos de memória (incluindo no mínimo 2 segmentos: (1) o segmento de texto do usuário [4KBytes de 0x00000000 a 0x0000FFFF]; (2) o segmento de texto do kernel [4KBytes de 0x00004000 a 0x0004FFFF, incluindo o exception handler que inicia em 0x00004180]). lembrar que um sistema mínimo deve também contar com: 
			(1) o segmento de dados do usuário [4KBytes, de 0x00020000 a 0x0002FFFF]; 
			(2) o segmento de pilha/heap do usuário [4KBytes, de 0x00030000 a 0x0003FFFF];
			(3) o segmento de dados do kernel [8KBytes, de 0x00050000 a 0x0006FFFF];
		Opcionalmente, deve-se poder gerar um segmento de dados externo [4KBytes, de 0x00010000 a 0x0001FFFF].
		2.2.2) Escreve e testa o código de boot para o MIPS, um código que atua imediatamente após o reset do processador e inicializa os registradores de controle do Cp0 com valores coerentes, e que também inicializa ponteiros adequadamente ($sp, $gp, etc.). O boot deve concluir com um salto (ou salto para subrotina) para o endereço 0x00000000, onde se encontra o código do programa do usuário.
	2.3) Rodrigo
		2.3.1) Gera o hardware de pelo menos um periférico para o MIPS, e integra este com o sistema MIPS+Cp0 para realizar a validação do processo de atendimento de interrupção gerada por periféricos.
		2.3.4) Escreve código fonte do kernel e/ou de usuário para testar a operação MIPS+Cp0+periférico se comunicando via interrupções externas.
        Teste a IA diretamente nos seus apps favoritos … Use o Gemini para criar rascunhos e editar conteúdo, e tenha acesso à IA de última geração do Google com o Gemini Pro por R$ 96,99 R$ 0 durante 1 mês
Reunião de Orientação, 20/03/2026 - TCC2 Emir Bráz de Araújo Marques Júnior
Presentes: Emir, Rodrigo e Ney
Link do Googledrive para materiais do TCC do Emir: https://drive.google.com/drive/folders/1DBpFxflJj4FA5cEN1k_TOdPidxexRXPg?ths=true
Link do Github para projeto do TCC do Emir: https://github.com/ufsctasks/thesis
Link para o projeto Overleaf do texto do TCC: https://www.overleaf.com/project/689e0dc91d576792debc5999

1) Esta reunião foi a da retomada da lista de tarefas do TCC e de seu detalhamento.

2) Ney havia pré-elaborado uma lista parcial de 8 (oito) tarefas, anotando os responsáveis atribuídos a cada uma delas, ver abaixo a listagem das mesmas.

3) Fundamental para a semana que vem é termos (responsabilidade de todos, Emir, Rodrigo e Ney) um cronograma de abril/2026 a novembro/2026 para estas tarefas e para outras que eventualmente surgirem como essenciais durante o processo de pensar sobre as 8 tarefas inicialmente pensadas.

4) Conversamos sobre o início real da escrita do TCC por Emir. O projeto Overleaf do TCC não é atualizado desde 04/11/2025, ver link acima. Ney solicitou que Emir priorize a Introdução e (mais importante neste momento) o Capítulo hoje denominado Capítulo 4 - Target Architecture. A ideia é que em 2025 evoluímos na definição das características do conjunto Hw+Sw a implementar e isto já pode ser descrito de forma precisa. Já temos um modelo de memória para aplicações embarcadas, um conjunto de registradores de controle bem definidos que existirão no Cp0, um conjunto de instruções que terão suporte de execução, etc.

5) Outro ponto, que não exploramos na reunião, mas que Ney acha muito importante, e que deve ser encaminhado de forma urgente é a análise de trabalhos no estado da arte, sua comparação e a consequente escrita do Capítulo hoje denominado Capítulo 3 - State of the Art. No GoogleDrive do trabalho temos o diretório Bibliografia, que contém o diretório Papers, com 11 artigos que coletamos para ler e resumir. Mãos à Obra!!

6) Tarefas de implementação pensadas antes desta reunião por Ney:
	I - Tarefas de Hardware
		I.1 - Desenvolver e executar um testbench que mostre a atual implementação do Cp0 de Emir validada por simulação.
			Supondo que o testbench será escrito em Sysem)Verilog, temos
			Responsáveis: Emir + Rodrigo + Turma do UVM (Carbone + Zambotto + um?)
		I.2 - Desenvolver e executar um testbench que mostre a atual implementação do MIPS_S com as novas instruções definidas para interagir com o Cp0 do Emir. A simulação pressupõe que o testbench emule o comportamento do Cp0.
			Responsáveis: Ney
		I.3 - Integrar os módulos de Hw acima (I.1 e I.2) em uma primeira versão do MIPS_S_Cp0, produindo um novo testbench e mostrando que este novo Hw funciona.
			Responsáveis: Todos (Emir, Rodrigo, turma do UVM e Ney)
		I.4 - Desenvolver uma UART capaz de interagir com o Cp0 e escrever e validar um testbench que exercite a operação da nova UART, sobretudo mostrando que ela é capaz de gerar um pedido de interrupção ao Cp0 de forma correta.
			Responsável: Ney
	II - Tarefas de Software
		II.1 - Desenvolver um código de boot mínimo para o MIPS_S_Cp0 e validar ele com o Mars.
			Responsável: Ney
		II.2 - Desenvolver um software de usuáriocapa de inicializar os módulos Count e Compare do Cp0, e que seja capaz de realizar o tratamento da interrupção causada por este par de módulos, validar este com o Mars e com o Vivado por simulação.
			Responsável: Emir
		II.3 - Concluir uma versão inicial do exception handler para o Cp0, validar este com o Mars e com o Vivado por simulação.
			Responsável: Emir
		II.4 - Desenvolver uma nova versão do software de le_mars (le_mars_Cp0??), capaz de gerar os módulos de memória BRAM a seguir:
				1) User Text Segment (0x0000 a no máximo 0x0FFF) 		2*2Kbytes = 4KB Word-addressed 
				2) Static User Data Segment (0x2000 a no máximo 0x2FFF)	2*2Kbytes = 4KB Byte-addressed
				3) Stack & Heap Segment (0x3000 a no máximo 0x3FFF) 	2*2Kbytes = 4KB Byte-addressed (empty?)
				4) Kernel Text Segment (0x4000 a no máximo 0x4FFF) 		2*2Kbytes = 4KB Word-addressed (Exception Handler starts at 0x4180)
				5) Kernel Data Segment (0x5000 a no máximo 0x6FFF) 		4*2Kbytes = 4KB Byte addressed 
				Validar este novo le_mars.
			Responsável: Ney