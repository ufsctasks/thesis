gostaria de fazer uma sessão no meu artigo onde será descrita como State os the Art. Gostaria que ela fosse baseada estruturalmente neste artigo:

A MACHINE LEARNING APPROACH FOR TRAFFIC ANOMALY DETECTION IN NOC-BASED MANY-CORES

ANGELO ELIAS DAL ZOTTO.

Mais especificamente nesse capítulo: (também vou anexa-lo para analise).

3. STATE-OF-THE-ART

This Chapter reviews and discusses related work regarding solutions to detect
threats in NoC-based many-cores. Each of the following sections is divided by the type of
algorithm used by the related work to detect such threats:
1. Section 3.1 lists solutions using classical algorithms, i.e., that do not apply machine
learning;
2. Section 3.2 describes solutions that do not use neural networks and are composed
by a single learner;

3. Section 3.3 presents proposals that use ensemble learners, i.e., combinations of mul-
tiple ML models to enhance performance, but that are not composed by neural net-
works;

4. Section 3.4 presents solutions using neural networks.
Finally, Section 3.5 discusses the related work presented in this Chapter.

3.1 Classical solutions

One way to detect anomalies in networks is using classical algorithms, such as
Dynamic Time Warping (DTW) [Bellman and Kalaba, 1959]. DTW is an algorithm that
measures the similarity between two time series, even if they vary in speed.

Diab et al. [2019] use DTW in computer networks to measure the distances be-
tween control and data planes of Transmission Control Protocol (TCP) packets. They iden-
tify when a sequence of distances is beyond predefined thresholds and consider it an

anomaly, concluding that the distance between the TCP control plane and corresponding
data plane should be within a certain range of values during benign traffic.
Zhan et al. [2020] propose an optimized DTW algorithm to detect anomalies in

computer network traffic. The approach begins by normalizing the captured network traf-
fic and dividing it into equal-length subsequences using sliding windows. DTW is then

employed to assess the similarities between any two subsequences. An anomaly score is

derived from this similarity score, with higher scores indicating greater dissimilarity be-
tween two subsequences. Subsequences whose scores exceed a predefined threshold are

subsequently identified as anomalous.

These works apply their proposed algorithms to offline datasets, specifically tar-
geting computer networks. In such networks, DoS attacks are often easily characterized

29

by sudden increases in traffic volume. However, due to differing latency and throughput

constraints, the same principles cannot be directly applied to NoCs. Furthermore, anoma-
lies in NoCs tend to be more subtle than in computer networks. Even brief contention on a

link in a NoC system can cause significant issues, such as a real-time application missing
its deadline.

In the early stages of research on threat localization in NoC-based MCSoCs, Ra-
jesh et al. [2015] introduced the Runtime Latency Auditor for NoCs (RLAN) as a tool to de-
tect subtle, condition-based DoS attacks. Figure 3.1 illustrates the architecture of RLAN.

The SoC Firmware (highlighted in orange) assumes responsibility for controlling the RLAN
Intellectual Property (IP) within this system. It is designed to insert a timestamp into the
packet stream before forwarding it to the Network Interface (NI). Upon receiving a packet
stream, the firmware then extracts the previously inserted timestamp to calculate the
packet’s latency.

Figure 3.1: RLAN architecture. SoC Firmware controls RLAN packet generation. Source:
Rajesh et al. [2015].

RLAN additionally includes a hardware IP that generates Proximal Analogous Pack-
ets (PAPs), which are slightly modified versions of existing packets, mirroring their size and

route. The SoC Firmware receives these PAPs and RLAN then assesses whether there is

a deviation in the PAP latency compared to the original packet’s latency. Repeated de-
viations trigger RLAN to flag abnormal network activity. To evaluate their proposal, the

Authors used an 8x8 NoC simulated with BookSim [Jiang et al., 2013], employing traffic

profiles from the PARSEC benchmark suite [Bienia et al., 2008] provided by Netrace [Hes-
tness et al., 2010]. They reported an average recall of 98.9% with a false positive rate

ranging from 0% to 17.88% across eight different scenarios involving single and multiple
applications running concurrently. The insertion of RLAN increased router area and power
by 12.73% and 9.84%, respectively, while PAP traffic augmented NoC latency by 5.47%.

However, the study did not account for certain factors that could impact the system’s per-
formance: (i) an HT might affect both the original packet and the PAP; and (ii) the use of

synthetic traffic may not accurately reflect actual application behavior, where latencies
can vary significantly based on the workload.

30

3.2 Single learner solutions

Research on threat detection in NoC systems has increasingly turned to ML due
to the limitations of methods solely relying on packet latency monitoring. Kulkarni et al.

[2016] present one of the earliest ML-based proposals for detecting anomalies in many-
core systems, specifically targeting address spoofing, route looping, and traffic diversion

attacks. Their research evaluates various ML algorithms, including KNN, LR, DT, and unsu-
pervised learning methods. Following a correlation analysis of different features extracted

from NoC traffic, they select the following attributes for algorithm evaluation:
• Source core of the message
• Destination core of the message
• Packet transfer path
• Distance, as defined by the packet hop count at each router

Figure 3.2 compares the average precision and recall for the three types of at-
tacks using supervised learning algorithms, as assessed by Kulkarni et al. [2016]. Results

from unsupervised learning are excluded from the graph due to their insufficient perfor-
mance. Notably, SVM and KNN (with k = 1) demonstrate better overall performance than

LR and DT. However, the Authors chose to implement SVM, considering its advantageous
balance between classification performance and hardware complexity.

Figure 3.2: Precision and recall for the three types of attacks detected by the six models
proposed by Kulkarni et al. [2016]. Adapted from: Kulkarni et al. [2016].
Figure 3.3 illustrates the architecture into which the SVM algorithm is integrated.
This architecture comprises a 16-core hierarchical NoC, implemented on a Field Programmable
Gate Array (FPGA), with a single Attack Detection Module that uses the proposed SVM. The
system employs synthetic traffic generated by a Traffic Generator Module that does not

31

accurately mimic real-world workloads. Another limitation is the NoC topology, which in-
cludes four routers, each one connected to four cores, and a central router connected to

these four routers. This particular design potentially limits the scalability of the proposed
solution. Nonetheless, the reported overhead for integrating the SVM algorithm into the
system is minimal, accounting for only 2% in area and 1% in power of the entire system.

Figure 3.3: FPGA platform consisting of a hierarchical NoC in tree topology with an external
SVM attack detection module. Source: Kulkarni et al. [2016].
Similarly, Vashist et al. [2019], besides evaluating KNN, SVM, and DT, also include
MLP. Their research focuses on eavesdropping and jamming DoS attacks in Wireless NoCs
(WiNoCs), characterized by sustained burst errors detected by an Error Correction Code
(ECC). In their approach, the number of burst errors within a block is the only feature
the machine learning classifier uses. Given the specific characteristics of their WiNoC
platform, they propose a clustered detection approach, incorporating a security unit within
each Wireless Interface (WI). The effectiveness of their system is tested using system-level
simulation with back annotated router RTL performance figures on an 8x8 many-core setup
with 4 WIs, employing synthetic traffic.
Table 3.1: Classifier performance for WiNoC eavesdropping and DoS detection obtained
by Vashist et al. [2019].

Classifier MLP SVM KNN DT
Precision 1.00 0.98 0.99 1.00
Recall 0.48 0.98 0.99 0.52

In Table 3.1, recall and precision scores are listed for each ML approach used by
Vashist et al. [2019]. Among the approaches, MLP with a single hidden layer with 20 nodes
and DT presented poor detection performance, evidenced by its low recall, but the Authors
do not justify this result. Both SVM and KNN (with k = 1) showed good classification

32

performance, but the Authors indicate that SVM could not detect sporadic variations, and
thus KNN is used in their final implementation. Their approach resulted in 2.6% and 4.2%
additional area and power, respectively, in relation to the WI.

Hu et al. [2023] proposed a cascaded methodology first to detect and then clas-
sify condition-based HTs. Following a correlation analysis, the Authors selected average

packet latency and average link utilization as the primary attributes for their research.
They assessed various algorithms for both detection and classification stages, including
SVM, Logistic Regression, KNN, DT, and RF. Figure 3.4 depicts their proposed workflow,
which consists of using SVM for attack detection followed by KNN for classification, with
the latter being fed by the output of the SVM. They tested their approach using the gem5
[Binkert et al., 2011] simulator along with Garnet [Agarwal et al., 2009] NoC, simulating an
8x8 NoC with synthetic traffic that exhibited distinct communication patterns. The results,
obtained offline, showed an average precision of approximately 0.87 and an average recall
of roughly 0.86. However, the Authors did not disclose any overhead metrics associated
with their approach.

Figure 3.4: Proposed attack detection and classification flow by Hu et al. [2023]. Source:
Hu et al. [2023].

3.3 Ensemble learner solutions

Yao et al. [2020] propose a method based on RF that simultaneously detects DoS
attacks in NoCs and localizes their source. To train their model, they consider the following
features:
• Source core of the message
• Destination core of the message
• Packet transfer path
• Time taken by the flit to traverse each router

33

They achieve an average precision of 1.0 and recall of 0.957 in detecting traffic
suffering from a DoS attack and a precision of 0.993 and recall of 0.950 in identifying the
traffic causing the DoS attack. However, the data is extracted using synthetic traffic in
a 4x4 mesh simulated with OPNET [2005] computer network simulator, which may lead
to inaccuracies. Furthermore, the Authors do not provide details on power, area, or the
implementation method of the detection system in the target platform.

Sudusinghe et al. detects flooding DoS [Sudusinghe et al., 2021] and eavesdrop-
ping attacks [Sudusinghe et al., 2022] using XGBoost [Chen and Guestrin, 2016]. They

claim their techniques can identify attacks in unpredictable NoC traffic patterns caused by
varying application mappings. Their experiments utilize the gem5 and Garnet simulators
in a 4x4 system configuration, consisting of shared memory with local caches at PEs. The
routers in their system are equipped with probes that collect relevant attributes at every
flit traversed in a router and send this data to a centralized unit for attack detection.
Sudusinghe et al. [2021] propose a Security Engine for detecting DoS attacks,
incorporating five distinct counters and indexes, along with the following attributes:
• Port used by the flit to exit the router
• Virtual channel
• Number of hops between source and destination
• Time taken by the flit to traverse the router
Sudusinghe et al. [2021] evaluate a range of machine learning models, including

NBC, KNN, DT, RF, LightGBM, XGBoost, and ANN ranging from 2 to 6 layers, for their effec-
tiveness in detecting DoS attacks. The accuracy of each model is detailed in Figure 3.5,

with XGBoost achieving the highest one. Despite not assessing other metrics, the Authors
select XGBoost for their final implementation, which computes the probability of a DoS

attack occurring within a specific time window. This probability is determined as the av-
erage of feature vectors classified as indicative of an attack within the window. In three

simulated scenarios, they report an average precision of 0.95 and an average recall of
0.96. However, the Authors evaluate their model using only one benchmark application,
the Fast Fourier Transform (FFT), which could potentially bias the results due to varying

computation and communication characteristics of different applications. While the clas-
sifier performance appears promising, the Authors do not provide details on the overhead

of the Security Engine IP. Moreover, they do not address potential scalability issues associ-
ated with a centralized approach, as this dedicated IP is singular for the entire many-core

system.

Sudusinghe et al. [2022] propose a Decision Unit to detect eavesdropping at-
tacks. In this work, the Authors offer limited details on the set of attributes used to train

34

Figure 3.5: Accuracy obtained by Sudusinghe et al. [2021] when detecting DoS attacks
using different ML models. Source: Sudusinghe et al. [2021].

their learning model but state that each router in each distinct test scenario has a different
subset of evaluated features, thus possibly biasing the results. They propose an algorithm

to select what models will be executed at each time in the Decision Unit based on a trig-
ger mechanism that selects only the PEs with a packet transfer ratio above a predefined

threshold. The ML algorithm is executed for the selected router and its neighbors. In this

work, the Authors evaluate LR, DT, RF, XGBoost, and MLP, and based on the model accu-
racy, they pick XGBoost to implement the final model. The average precision ranges from

0.789 to 0.988, while recall ranges from 0.770 to 0.985 in 6 attack scenarios with 50% of
the information snooped. The Authors use the PARSEC benchmark suite to evaluate the
model in this work. They also do not present the overhead of the Decision Unit, which is
centralized. It is possible that the scalability is not an issue in their approach since the
model is executed for a filtered subset of PEs, but this is not possible to confirm without
knowing the area overhead of the Decision Unit IP.

3.4 Neural Network Proposals

Madden et al. [2018] employ SNN to identify flooding DoS attacks, considering
spatial and temporal variations. The only attribute used as input is the request-to-send
signal from the output ports of the routers. Their approach is centralized and comprises
three fully connected layers. Figure 3.6 illustrates their proposed architecture, in which

the SNN features one input neuron for each input port in the NoC and an equivalent num-
ber of neurons in a single hidden layer. The evaluation is conducted in a system with 16

PEs, using synthetic traffic modeled from a “multimedia-system” [Liu et al., 2015], simu-
lated with Noxim [Catania et al., 2016]. As the model evaluation is performed offline, no

overhead metrics are provided. The Authors claim 86% average accuracy, but this result
has low confidence because not every assessed scenario has balanced classes.

35

Figure 3.6: Test setup proposed by Madden et al. [2018], where the input ports of every
router in the many-core are connected to the SNN. Source: Madden et al. [2018]

Sniffer [Sinha et al., 2021] is a detection and localization Perceptron for flooding-
based DoS caused by Malicious IP (MIP). They evaluate their proposal on an 8x8 NoC

configuration with the Rodinia benchmark suite [Che et al., 2009]. The attributes used
as inputs to the Perceptron are:
• Time taken by a flit in the input buffer
• Time between the reception of two flits in the input ports
• Buffer utilization in each virtual channel

Sniffer presented an average precision of 0.984 and recall of 0.983 for DoS de-
tection. Figure 3.7 illustrates the Sniffer architecture, with the Perceptron shown in (a).

The router (b) is modified in their proposal, which is not feasible if the router itself is a
MIP, and their Perceptron detection IP is inserted in every router, which can only yield low
overhead in systems such as the one presented in their work, with x86 cores. Moreover,
the work is evaluated using gem5 and Noxim, which can lead to inaccurate results, such
as their claimed 3.3% area and 3.92% additional area and power, respectively, in relation
to the router.
DetectANN [Wang et al., 2020] and AGAPE [Wang et al., 2022] are two approaches
to detect HTs using ANN.
DetectANN is a fully-connected 3-layer Artificial NN (ANN) to detect injected faults,
with the hidden layer composed of 30 neurons using the sigmoid activation function. The
Authors use the following attributes:
• Buffer utilization in each router virtual channel
• Link utilization in each router input port

36

Figure 3.7: Sniffer architecture, with the perceptron architecture (a) and the modified
router (b). Source: Sinha et al. [2021].

• Router temperature
• Transient error rate detected by an ECC Decoder

DetectANN is evaluated using gem5 to simulate an 8x8 many-core with out-of-
order processors with a 2-level cache using synthetic traffic mixed with PARSEC bench-
mark traffic. Still, only the detection accuracy of about 95% is provided, and that can be a

misleading metric when provided without further details if the test dataset is unbalanced.
The claimed low overhead of 0.9% of router area is due to adopting complex routers with
Multiple Physical NoCs (MPN) and Virtual Channels (VC), along with the low confidence of
area metrics when obtained with simulators, such as gem5, instead of RTL synthesis.
AGAPE employs a GAN to detect injected faults, misrouting, and packet drops
caused by HTs. This detection process involves reconstructing the attribute time series
into matrices and applying computationally demanding convolution layers, as depicted in

Figure 3.8. After the offline training phase, the Generator is discarded, and only the Dis-
criminator is used for classification. In addition to the attributes DetectANN uses, AGAPE

also incorporates the retransmission rate of each output port and the average packet end-
to-end latency. Although it is assessed with the PARSEC benchmark suite and gem5, the

lack of detailed information on the many-core system lowers the confidence in the claimed
area overhead of 7.2% relative to the router.
Table 3.2 presents the precision and recall scores for the three types of attacks
that AGAPE can detect. The results show high classification performance for fault-injection

attacks but a notably lower precision for misrouting and packet-drop detection. It is impor-
tant to note that packet drops can lead to catastrophic failures in NoCs, as their intra-chip

37

nature typically does not account for packet loss, rendering the detection of packet drops
in such environments both impractical and unfeasible.

Figure 3.8: GAN architecture used by AGAPE. Adapted from: Wang et al. [2022].

Table 3.2: Classifier performance obtained by AGAPE.
HT Fault-injection Misrouting Packet-drop
Precision 0.873 0.770 0.802
Recall 0.962 0.928 0.979

Figure 3.9 shows the router architecture proposed by Wang et. al [Wang et al.,
2020, 2022] in both DetectANN and AGAPE. Note that the ANNs (HT Detection) are inserted
at every router of the many-core, leading to significant area overhead. In addition to this
drawback, the insertion of ANN in these works is invasive in the router design, requiring
total control over an IP that an HT might infect.

Figure 3.9: Router architecture of DetectANN and AGAPE. Source: Wang et al. [2022].

38

3.5 Related work analysis

Table 3.3 presents the related work summary. The columns are organized as
follows:
• The first column lists the work presented in this Chapter. Works [Diab et al., 2019;

Zhan et al., 2020] are omitted because their threat detection aims at computer net-
works instead of NoCs.

• The second column lists the detection method used by the Authors and its main
characteristics.
• The third column lists the types of threats detected by each work.
• The fourth and fifth columns present the precision and recall metrics, respectively,
for the corresponding method.
• The sixth column lists the topology of each solution, i.e., where the detection method

is placed in the many-core, whether it is a single detector in a many-core (central-
ized), multiple detectors (distributed), or one detector for each router. Note that

some works are not assessed in runtime. Therefore, they are classified as offline.
• The seventh column in the table lists the overhead as reported by the Authors. For
some works, the confidence in these reported data is low. Such instances are marked

as claimed overhead values. The justification for this low confidence in certain re-
ported overheads is justified later in this Chapter.

• The eighth column lists the traffic profile used to generate data for the proposed
method.
• Finally, the ninth column presents the modeling strategy of the work. This column
lists whether a simulation tool is used, if the system is modeled in RTL, or if a custom
implementation was made in FPGA. Furthermore, the column details the many-core
size, the processor architecture, or if only the NoC was modeled.
The last line of Table 3.3 presents the work proposed in this Thesis.

39

Table 3.3: Related work summary. ND: No Data.

Author Method Attacks Detected Precision Recall Topology Overhead Traffic Profile Modeling
Rajesh et al. [2015] Ad-hoc Condition-based subtle DoS ND 0.989 On every router

12.73% area and
9.844% power w.r.t.
router (claimed);
5.47% NoC latency

PARSEC (Netrace) BookSim (8x8 NoC-only)

Kulkarni et al. [2016] SVM (4 attributes)

Address spoofing 0.94 0.94

Centralized 2% total area; 1% total

power Synthetic FPGA (16 cores, 5 routers) Route looping 0.95 0.95 Traffic diversion 0.94 0.93
Madden et al. [2018] SNN (1 attribute, 3 fully-connected layers) Flooding DoS ND ND Offline ND Synthetic Noxim (4x4 NoC-only)
Vashist et al. [2019] KNN (1 attribute, k = 1) Eavesdropping; Jamming DoS 0.99 0.99 Clustered 2.6% area and 4.2% power w.r.t. WI Synthetic System-level simulator (8x8 NoC-only, 4 WIs)
Wang et al. [2020]

ANN (14 attributes, 3
fully-connected layers,
30 neurons in the
hidden layer, sigmoid)

Injected faults ND ND On every router 0.9% area w.r.t. router (claimed) Synthetic; PARSEC gem5 (8x8, 2-level cache, out-of-order)
Yao et al. [2020] RF (4 attributes) DoS-affected traffic 1.0 0.957 Offline ND Synthetic OPNET (4x4 NoC-only) DoS-causing traffic 0.993 0.950
Sinha et al. [2021] Perceptron (3 attributes) Flooding DoS 0.984 0.983 On every router 3.3% area and 3.92% power w.r.t. router (claimed) Rodinia gem5 + Noxim (8x8, 8 x86 out-of-order processors)
Sudusinghe et al. [2021] XGBoost (9 attributes) Flooding DoS 0.95 0.96 Centralized ND FFT application

gem5 + Garnet (4x4
cached with shared
memory)
Sudusinghe et al. [2022] XGBoost (varied attributes per router) Eavesdropping 0.924 0.915 Centralized (condition- activated) ND PARSEC gem5 + Garnet (4x4 cached with shared memory)
Wang et al. [2022]

GAN discriminator (19
attributes, 5
convolution layers)

Injected faults 0.873 0.962
On every router 7.2% area w.r.t. router (claimed) Misrouting 0.770 0.928 PARSEC gem5 (ND) Packet-drop 0.802 0.979
Hu et al. [2023] SVM (2 attributes) Condition-based HTs 0.87 0.86 Offline ND Synthetic gem5 + Garnet (8x8 NoC-only)
This Thesis

XGBoost (4
attributes,

per-application-
profiling) Subtle DoS

0.956

(prelimi-
nary)

0.978

(prelimi-
nary)

Offline;
Distributed
(planned)

Low, parallel
software-based
(planned)

Realistic workloads
with complete software
stack

RTL simulation

40

Table 3.3 contains eleven works using ML to detect threats in many-cores. ML is

a potential solution for threat detection, which can consider different variations in work-
loads that classical algorithms cannot handle. However, state-of-the-art ML techniques for

anomaly detection in NoCs are limited in applicability and confidence.
The first issue, applicability, is due to the use of costly techniques. We identified
the following applicability limitations in the state-of-the-art:
Limitation 1. Scalability: three works [Kulkarni et al., 2016; Sudusinghe et al., 2021,
2022] use centralized machine learning solutions. This poses a scalability issue due to:

(i) the ML model increases its inputs as the many-core increases its size; and (ii) receiv-
ing monitoring messages from the entire system can become unfeasible as the system

increases its size. The same is valid when the ML model directly probes the system: as
the system increases its size, the probes are farther from the classifier. Only Vashist et al.
[2019] propose a distributed approach that may not compromise scalability.
Limitation 2. Model overhead: a distributed organization possibility is placing a threat
detector at every router. Four works [Rajesh et al., 2015; Wang et al., 2020; Sinha et al.,
2021; Wang et al., 2022] insert its proposed model in every router. This poses a significant
overhead in terms of area and power, mainly if the proposed model is complex and has
many attributes, such as the ANNs proposed in some of these work [Wang et al., 2020,
2022]. A significant overhead can also occur in a centralized approach, such as the one
proposed by Sudusinghe et al. [2022], that uses a different model for each router. Such
models will incur a significant overhead, even if they are concentrated in a single detector
IP.
Limitation 3. Offline classification: the remaining three works [Madden et al., 2018;
Yao et al., 2020; Hu et al., 2023] obtain their results offline, i.e., they are not applied in
runtime to the target platform. Because the model is not properly implemented at runtime,
obtaining data about scalability or overhead is impossible.
Limitation 4. Monitoring overhead: the work proposed by Rajesh et al. [2015] audits
up to 80% of packets in the NoC, i.e., it increases the traffic by 80%, given that for auditing,
it needs to replicate a packet and send it to a similar route. Some works [Kulkarni et al.,
2016; Madden et al., 2018; Yao et al., 2020; Sudusinghe et al., 2021, 2022] obtain their
data on every hop traversed by a flit from all routers in the NoC to infer using its model.
The traffic overhead becomes unfeasible when every flit traversing the NoC generates one
or more monitoring flits to send to the ML classifier containing the feature vector. Other
works [Wang et al., 2020; Sinha et al., 2021; Wang et al., 2022] do not incur monitoring
overhead in NoC traffic due to inferring the model in every router. Still, they also obtain a
feature vector for every flit traversing the router. This is also unfeasible because inferring
the model for every flit increases the power and performance overheads. Only the works
proposed by Vashist et al. [2019] and Hu et al. [2023] use averaged metrics instead of
feature vectors extracted in every hop traversed by a flit.

41

Limitation 5. Router modification: three works [Vashist et al., 2019; Wang et al., 2020;
Sinha et al., 2021; Wang et al., 2022] modify their routers to apply their model. This is not
feasible when assuming that the router is the target of a MIP or when it is a 3PIP.
The second issue, confidence, is due to the adoption of synthetic NoC traffic
that does not represent real application scenarios and the use of high-level simulations,
not reflecting the actual accuracy of the systems. We identified the following confidence
limitations in the state-of-the-art:
Limitation 6. Many-core model confidence: six works [Wang et al., 2020; Sinha et al.,
2021; Sudusinghe et al., 2021, 2022; Wang et al., 2022; Hu et al., 2023] use gem5 to

model its architecture, that can provide an arbitrary accuracy depending on the imple-
mented models [Binkert et al., 2011]. Half of the works using gem5 also use Garnet to

model the NoC [Hu et al., 2023; Sudusinghe et al., 2021, 2022]. Garnet is a Python-based
simulator, thus providing low confidence in area and power metrics. Two works [Madden
et al., 2018; Sinha et al., 2021] use Noxim to model the NoC. Experiments made by the
Author’s research group with several NoC models show that results obtained with Noxim
deviate far from the ones obtained with a clock cycle-accurate simulator. Yao et al. [2020]
use OPNET, a network simulator, thus neglecting both the characteristics of NoCs and

embedded systems. Vashist et al. [2019] model their work using an unspecified system-
level simulator. System-level simulators will provide similar-to-worse accuracy compared

to other simulators, such as gem5. Only the work proposed by Kulkarni et al. [2016] uses
an RTL model, evaluating in FPGA, although with only five routers.

Limitation 7. Classification performance confidence: two works only provide an ac-
curacy metric of their results [Madden et al., 2018; Wang et al., 2020], which alone cannot

represent the actual performance of the ML model. Rajesh et al. [2015] provide the re-
call of its detection alongside other metrics but does not disclose precision to properly

evaluate the trade-off between precision and recall.
Limitation 8. Synthetic traffic: about half of the proposals generate synthetic traffic
to assess their models [Kulkarni et al., 2016; Madden et al., 2018; Vashist et al., 2019; Yao
et al., 2020; Hu et al., 2023]. Using synthetic traffic does not accurately model a system
because it neglects the complexity of a many-core that can contain a PE with a processor
executing a multi-tasking Operating System (OS) and multiple NoCs in the same SoC.
Furthermore, the evaluation with a single benchmark [Sudusinghe et al., 2021] suffers
from similar drawbacks as work using synthetic traffic.
Limitation 9. Attacks easy to detect: three works propose detecting flooding DoS
[Madden et al., 2018; Sudusinghe et al., 2021, 2022]. Due to the nature of flooding DoS,

which overwhelms its target with packets, it is easy to detect with thresholds, and there-
fore, applying ML may not be the most suited approach. Otherwise, Wang et al. [2022] also

propose detecting packet drops, which is unusual for occurring in NoCs, and is frequently
ignored, as a packet drop would cause the system to enter an undefined state.

42

Limitation 10. NoC-only systems: about half of the works propose threat detection in
NoCs without accounting for the complexity of MCSoCs, which can include multiple NoCs,
heterogeneous processors, and a complete software stack [Yao et al., 2020; Hu et al.,

2023; Rajesh et al., 2015; Madden et al., 2018; Vashist et al., 2019]. These works as-
sess only the NoC traffic, and even the work by Rajesh et al. [2015], which uses network

traces from a benchmark, cannot accurately represent the full complexity of those sys-
tems. Moreover, Wang et al. [2020] and Sinha et al. [2021], through the use of high-level

simulators, use complex processors in their systems with out-of-order, x86 architecture,
or hierarchical caches, that do not apply to embedded systems.
The work proposed in this Thesis is designed to mitigate the limitations found in
current state-of-the-art research in the following ways:

• Limitations 1, 4, and 8: The implementation of a Management Application, de-
tailed in Chapter 4, ensures scalability and low monitoring overhead. Additionally,

using an actual many-core system enables real traffic generation from benchmarks.

• Limitation 2: The approach ensures low overhead by employing simple software-
based models that use a few attributes and run in parallel with user applications.

• Limitation 3: While the classification in this work is currently conducted offline, we
propose to implement it at runtime in Chapter 6.
• Limitations 5, 6, and 10: This work uses an MCSoC modeled entirely at the RTL
level with a complete software stack, thus enhancing model confidence. It does not
need any modifications to routers.

• Limitations 7 and 9: Appropriate metrics are employed to evaluate the perfor-
mance of the proposed detection mechanism. This work focuses on subtle DoS at-
tacks that do not flood the NoC, thereby presenting a more challenging detection

scenario.

os meus artigos em questão são esses:

1- 1982-ACMSigM_Hennessy&Jouppi_MIPS-a-UpArch
2- 1988-Chris Rowen_MIPS_R3010_floating_point_coprocessor
3- 2008-DAC_Pinckney-etal_A-MIPS-R2000-Implem
4- 2016-EWME_Harris-etal_MIPSfpga-HOn-LearningCommSoftCore
5- 2017-EIConRus_Liventsev-etal_ExtMIPSfpga-ISet-for-NavDP
6- 2017-IETCDS_Harris-etal_MIPSfpga-CommMIPS-SCore-in CA-Educ
7- 2022-BDICN_Ji&Chen_Des&Implem-MIPS-Exp-PlatBased-on-FPGA
8- 2022-IT&QM&IS_Romanov-etal_Use-SchoolMIPS-SPCore-for-Teaching
9- 2023-IITCEE_Avinash-etal_DesImpl32b-MIPS-5-Stage-PipeDThCTrl
10- 2025-AirUnivTR_Rehan_DEs&Impl-32-bitMIPS
11- 2025-CCWC_Sharif-etal_DesImpl-32b-MIPSoftProc-Enh-IS-on-FPGA

em ordem cronológica.

Com a leitura eu separei esses ponto principais:

1- 

MIPS A microprocessor Architeture.

As instruções de comparação e desvio são codificações diretas da micromáquina: o estágio de decodificação de operandos calcula o endereço de destino do desvio (*branch target*), e o ciclo de execução realiza a comparação. Todas as instruções de desvio possuem um atraso de uma instrução no seu efeito; ou seja, a próxima instrução sequencial é sempre executada (*branch delay slot*).

**Outras instruções** — incluem chamadas de procedimento e tratamento de interrupções. As instruções de ligação de procedimento (*procedure linkage*) também se encaixam naturalmente no formato da micromáquina, combinando cálculo de endereço efetivo com operações registrador–registrador.

O MIPS é uma máquina endereçada por palavra (*word-addressed*). Isso oferece várias vantagens importantes de desempenho em relação a arquiteturas endereçadas por byte. Primeiro, o uso de endereçamento por palavra simplifica a interface de memória, já que não é necessário hardware para extração e inserção de bytes. Isso é particularmente importante, pois as operações de busca e armazenamento de instruções e dados estão no caminho crítico.

Segundo, quando dados em byte (como caracteres) podem ser manipulados em blocos de palavra, a computação se torna muito mais eficiente. Por fim, a efetividade de deslocamentos curtos (*offsets*) a partir de um registrador base é multiplicada por um fator de quatro.

A solução adotada para esse problema foi separar os sistemas de memória de dados e de instruções. A separação entre programa e dados é uma prática comum em diversas arquiteturas; no sistema MIPS, isso permite aumentar significativamente o desempenho.

Outro benefício dessa separação é a possibilidade de utilizar cache apenas para instruções. Como a memória de instruções pode ser tratada como somente leitura (*read-only*), exceto durante o carregamento do programa, o controle do cache torna-se mais simples.

**início da arquitetura Harvard (separação instrução/dado)**

A arquitetura MIPS oferece suporte a falhas de página (*page faults*), interrupções externas e *traps* geradas internamente (como *overflow* aritmético). O hardware necessário para lidar com esses eventos em uma arquitetura pipelineada costuma ser grande e complexo. Além disso, essa é uma área em que a falta de suporte adequado em hardware torna inviável a construção de software de sistema.

No entanto, como o conjunto de instruções do MIPS não é interpretado por um microengine com estado próprio, o suporte em hardware para falhas de página e interrupções é significativamente simplificado.

Para tratar corretamente interrupções e falhas de página, duas propriedades importantes são necessárias:

1. A arquitetura deve garantir o encerramento correto do pipeline, sem executar quaisquer instruções que causaram falha (por exemplo, a instrução que gerou o *page fault*). Muitos microprocessadores atuais não conseguem realizar essa função corretamente (como Motorola 68000, Zilog Z8000 e Intel 8086).
2. O processador deve ser capaz de restaurar corretamente o pipeline e continuar a execução como se a interrupção ou falha não tivesse ocorrido.
3. 

O problema de reorganização é discutido em detalhe em outro artigo; nele, é demonstrado que o problema é NP-completo, e um conjunto de soluções heurísticas é proposto. O algoritmo de reorganização é essencialmente um algoritmo de escalonamento de instruções (*instruction scheduling*). O algoritmo básico é:

1. Ler o programa em linguagem assembly e criar um grafo acíclico direcionado (*DAG*) que representa as relações de precedência entre as instruções.
2. Determinar quais grupos de instruções podem ser escalonados para execução em seguida e eliminar os demais.
3. Escolher heurísticamente uma instrução entre as que podem ser executadas. Tentar selecionar uma instrução que possa ser empacotada com a última instrução executada e que permita que o restante do código seja escalonado com um número mínimo de *no-ops*.

Todo o processador MIPS já foi projetado (*layout*) e particionado em um conjunto de seis chips de teste que cobrem todas as funções de caminho de dados (*data path*) e controle do chip. Quatro desses chips de teste foram enviados para fabricação até agosto de 1982; espera-se que os demais também sejam enviados ainda durante agosto de 1982.

Na área de software, foram desenvolvidos geradores de código para as linguagens C e Pascal. Esses geradores produzem instruções simples, dependendo de um reorganizador de pipeline. Uma versão completa do reorganizador de pipeline já está em funcionamento. Um simulador em nível de instrução está sendo utilizado para estimar o desempenho.

2- The MIPS R3010 Floating-Point Coprocessor

Essas extensões de ponto flutuante incluem as mesmas formas das operações inteiras do R3000: carregamentos (*loads*) e armazenamentos (*stores*), movimentação entre registradores, comparações, operações aritméticas e desvios (*branches*).

O benefício mais significativo de um coprocessador fortemente acoplado ocorre em uma ampla classe de problemas científicos e de engenharia que não se adaptam bem à vetorização de código. Esses problemas não estruturados exigem baixa latência tanto em acessos à memória quanto em operações aritméticas. A arquitetura do R3000 reduz significativamente a latência efetiva de memória por meio do uso de um grande cache de dados de alta velocidade e técnicas de recarga em bloco (*block-refill*).

O R3010 alcança operações aritméticas de alta velocidade por meio da interação de quatro decisões importantes de projeto:

- O forte acoplamento da unidade de ponto flutuante (FPU) com a CPU reduz a sobrecarga de emissão de instruções e auxilia no tratamento preciso de condições numéricas excepcionais. Essa escolha garante compatibilidade com o padrão IEEE sem perda de desempenho.
- Compiladores com otimização global exploram um grande conjunto de registradores de ponto flutuante (dezesseis registradores de 64 bits), eliminando computações desnecessárias e tráfego de memória.
- Uma implementação sem microcódigo (ou seja, com lógica dedicada — *hardwired*) aumenta a velocidade das operações essenciais em precisão simples (32 bits) e dupla (64 bits) no padrão IEEE. Como consequência, funções menos frequentes (como trigonométricas e hiperbólicas) são tratadas por software em bibliotecas escritas em assembly, permitindo que a maior parte da área de silício seja dedicada às operações mais comuns e críticas em termos de desempenho.
- Unidades funcionais independentes permitem que até quatro instruções de ponto flutuante sejam executadas em paralelo.

O desempenho disponível em ponto flutuante é comparado com três outros sistemas populares na comunidade de engenharia e científica, incluindo o DEC VAX.
O tempo de execução de qualquer programa pode ser expresso como o produto do número de instruções executadas, do número médio de ciclos por instrução e do tempo de ciclo do processador. Ao projetar o par de processadores RISC R3000/R3010, optou-se por reduzir tanto o tempo de ciclo quanto o número de ciclos por instrução.
Como resultado, o hardware implementa diretamente as operações essenciais de ponto flutuante: adição, subtração, multiplicação, divisão, comparação, conversão entre formatos, valor absoluto e negação. O software de sistema fornece as funções mais complexas e, ao fazê-lo, se beneficia da rápida execução das operações aritméticas básicas subjacentes.
A Tabela 1 apresenta o número de ciclos para operações importantes de ponto flutuante, tanto em precisão simples quanto dupla.
Outros coprocessadores de ponto flutuante em um único chip implementam essas operações básicas por meio de longas sequências de microcódigo, que levam de três a treze vezes mais ciclos do que o R3010. A Tabela 2 compara o número de ciclos necessários para realizar operações aritméticas em precisão dupla no R3010 e na FPU Motorola MC68882. São consideradas tanto operações entre registradores quanto operações envolvendo memória e registrador.

**Arquitetura de coprocessadores**

A arquitetura RISC inclui coprocessadores fortemente acoplados como parte integrante do seu projeto. Cada um dos quatro coprocessadores (denominados de 0 a 3) interpreta simultaneamente o fluxo comum de instruções buscado pela CPU R3000, executa operações em conjuntos de registradores privados e realiza cargas e armazenamentos de operandos/resultados no cache de dados compartilhado.

O Coprocessador 0, que é implementado no próprio chip do processador R3000, é responsável pelo gerenciamento de memória e funções de controle do sistema. O Coprocessador 1, representado pelo chip R3010, é dedicado a operações de ponto flutuante binário. Os Coprocessadores 2 e 3 permanecem indefinidos e disponíveis para futuras extensões da arquitetura.

A execução compartilhada entre os coprocessadores e a CPU reduz a complexidade e o número de pinos dos coprocessadores, sem comprometer o desempenho.

Para operações de *load* do Coprocessador 1 (R3010), a CPU soma o registrador base com o deslocamento para formar um endereço virtual, traduz esse endereço para físico (via Coprocessador 0) e envia o endereço físico ao cache de dados. A CPU verifica a *tag* do cache enquanto o R3010 captura os dados. A CPU gerencia o recarregamento (*refill*) a partir da memória principal em caso de falha de cache (*cache miss*). Se necessário, os operandos também podem ser movidos entre os registradores de propósito geral da CPU e os registradores de dados ou controle do R3010.

As instruções de ponto flutuante normalmente especificam um registrador de destino e dois registradores fonte, além do formato. Os registradores do R3010 são referenciados por instruções de *load*, *store* e movimentação como trinta e dois valores de 32 bits, mas as operações aritméticas tratam esses registradores como dezesseis valores de 64 bits. Cada um dos 16 registradores pode armazenar um operando em precisão simples (32 bits) ou dupla (64 bits).

Os registradores de controle de ponto flutuante incluem um registrador somente leitura para identificação da versão (*revision identity*) e um registrador de status contendo modos de arredondamento, controle de exceções IEEE e bits de condição. A Figura 2 resume a organização dos registradores e os três tipos de instruções de ponto flutuante.

Quatro unidades funcionais aritméticas independentes no R3010 (registradores, soma, divisão e multiplicação) interagem com uma unidade de controle responsável pelo escalonamento e gerenciamento. A unidade de controle monitora as transferências entre a CPU R3000 e o cache de instruções e interpreta cada operação de ponto flutuante.

Sempre que a CPU necessita do resultado de uma instrução de ponto flutuante (COP1) antes que a operação tenha sido concluída, a unidade de controle sinaliza para que a CPU aguarde. Caso a CPU detecte uma condição excepcional (como uma falha de cache ou uma interrupção externa), ela interrompe (*shuts down*) o pipeline de execução de ponto flutuante, permitindo que instruções incompletas sejam reiniciadas posteriormente sem inconsistências numéricas.

A unidade de controle também agenda a execução de cada instrução entre as quatro unidades aritméticas.

**Implementação da Unidade de Multiplicação**

O R3010 utiliza uma versão levemente aprimorada do algoritmo tradicional de deslocamento e soma (*shift-and-add*) para multiplicação. Ele calcula uma soma acumulada de produtos parciais, onde o n-ésimo produto parcial é o multiplicando deslocado n bits à direita e logicamente ANDado (multiplicado) com o n-ésimo bit mais significativo do multiplicador.

Essa versão simples, implementada em hardware (*hardwired*), do algoritmo de multiplicação binária “no papel e lápis” tem seu desempenho aumentado por três modificações:

1. Bits do multiplicador codificados em Booth (*Booth encoding*) reduzem o número de iterações de deslocamento e soma de 56 para 28, reduzindo o tempo de multiplicação pela metade.
2. Somadores do tipo *carry-save* aceleram as iterações, pois não há atraso de propagação de carry (*carry-chain delay*).
3. O hardware calcula o dobro de bits por iteração ao utilizar pares de somadores *carry-save* em vez de um único. Um somador do par processa os produtos parciais de índices pares, enquanto o outro processa os de índices ímpares.

**Implementação da Unidade de Divisão**

Diferentemente da unidade de multiplicação, a unidade de divisão normalmente precisaria realizar uma subtração com propagação completa de *carry* (*carry-propagate*) em cada iteração, para determinar o sinal do resto parcial na próxima iteração. Mas será que isso é realmente necessário?

Um método proposto por Atkins, chamado **Divisão SRT Redundante de Radix Mais Alto (*Higher Radix Redundant SRT Division*)**, explora uma técnica de codificação na qual *m* símbolos representam *n* valores (*m > n*). Esse método permite construir um divisor que não precisa realizar propagação completa de *carry* a cada iteração.

O R3010 utiliza uma variante desse esquema — um algoritmo de radix 4, redundante e não restaurador (*nonrestoring*) — empregando cinco símbolos: 2, 1, 0, -1 e -2.

O chip utiliza somadores do tipo *carry-save* na mantissa em vez de somadores com propagação de *carry*, o que proporciona um ganho significativo de desempenho: em cada ciclo do R3010, são realizadas duas iterações (ou seja, 4 bits do quociente por ciclo).

3- A MIPS R2000 IMPLEMENTATION

**1. Introdução**

MIPS é uma família de processadores de 32 e 64 bits utilizada em diversas aplicações embarcadas, incluindo roteadores de rede, PDAs e consoles de jogos como o Sony PlayStation Portable. Um processador MIPS é classificado como um processador do tipo *Reduced Instruction Set Computer* (RISC), devido ao seu pequeno número de instruções e modos de endereçamento, em contraste com arquiteturas *Complex Instruction Set Computer* (CISC), como a arquitetura Intel x86.

A abordagem RISC privilegia menor complexidade para simplificar a implementação em hardware, apoiando-se na otimização por software. Exemplos de processadores RISC incluem ARM, DEC Alpha e o próprio MIPS. Processadores modernos da Intel e AMD baseados em x86 são “semelhantes a RISC”, pois implementam unidades de execução RISC e utilizam microcódigo para executar instruções CISC.

Como parte da disciplina E158: *Introduction to CMOS VLSI*, trinta estudantes de graduação do Harvey Mudd College, orientados pelo professor David Money Harris, e quatro estudantes da University of Adelaide, orientados pelo professor Braden Phillips, projetaram, fabricaram e testaram um processador MIPS compatível com o R2000 em um semestre.

2. Microarquitetura MIPS

A arquitetura MIPS inclui trinta e dois registradores de propósito geral de 32 bits e cinquenta e oito instruções, cada uma com 32 bits. Alguns processadores R2000 possuem unidades de ponto flutuante (FPUs) externas. O projeto descrito não incluiu suporte a FPU.

As instruções são lidas do cache de instruções durante o estágio de *fetch*, a partir do endereço de memória armazenado no contador de programa (PC). Durante o estágio de *decode*, os dados são lidos de um banco de registradores com três portas (*triple-ported register file*), e o controlador configura como a instrução será manipulada em cada estágio, iniciando uma máquina de estados. Saltos (*jumps*) e desvios (*branches*) também podem ocorrer nesse estágio.

As instruções são lidas do cache de instruções durante o estágio de *fetch*, a partir do endereço de memória armazenado no contador de programa (PC). Durante o estágio de *decode*, os dados são lidos de um banco de registradores com três portas (*triple-ported register file*), e o controlador configura como a instrução será manipulada em cada estágio, iniciando uma máquina de estados. Saltos (*jumps*) e desvios (*branches*) também podem ocorrer nesse estágio.

Para garantir esse comportamento, o processador trata exceções apenas quando a instrução causadora está no estágio de *execute*. Exceções detectadas no estágio de *decode* (como a instrução *break*) são atrasadas até o estágio de *execute*. Isso permite que todas as instruções anteriores sejam concluídas corretamente.

O endereço da instrução que causou a exceção e o tipo da exceção são armazenados no coprocessador, e a execução é redirecionada para um endereço de memória fixo (*hard-coded*), onde reside o tratador de exceções.

O chip suporta um subconjunto das exceções do R2000:

- Detectadas no estágio de *decode*:
    - Breakpoint
    - Syscall
    - Opcode inválido
    - FPU indisponível
- Detectadas no estágio de *execute*:
    - Load desalinhado (*Misaligned Load*)
    - Store desalinhado (*Misaligned Store*)
    - Overflow aritmético

As interrupções são tratadas como qualquer outra exceção no estágio de *execute*, com a diferença de serem geradas por um pino externo.

A Figura 2 mostra o sistema de memória no chip. Diferentemente das implementações originais do R2000, que não possuíam caches internos, este projeto utiliza dois caches separados de 512 bytes no chip: um para instruções e outro para dados.

Os caches físicos podem ser trocados entre si (o cache de instruções pode se tornar o de dados e vice-versa), o que é útil durante a inicialização.

Os dados são armazenados em cache quando o endereço de memória está no intervalo:

- **0x8000 0000 a 0x9FFF FFFF** (cache habilitado)

E não são armazenados em cache quando estão no intervalo:

- **0xA000 0000 a 0xBFFF FFFF** (cache desabilitado)

A nossa implementação do MIPS também inclui uma unidade dedicada de multiplicação/divisão (*multdiv*), capaz de realizar operações de multiplicação e divisão com inteiros com e sem sinal. Ela utiliza um algoritmo de Booth de radix 4 para multiplicação e um algoritmo sucessivo de deslocamento e subtração (*shift-and-subtract*) para divisão.

Uma instrução de multiplicação ou divisão carrega a unidade *multdiv* com os valores de entrada apropriados e inicia sua execução. No entanto, a CPU continua executando as instruções seguintes normalmente. A CPU só entra em *stall* quando há uma tentativa de leitura de **prodh/prodl** antes da conclusão da operação.

Um programa bem escrito pode iniciar uma multiplicação, continuar executando outras instruções úteis e somente ler o resultado quando o cálculo estiver concluído.

4 Validação

Um *testbench* em Verilog executa cada programa no processador simulado, permitindo que falhas sejam facilmente rastreadas até um subsistema específico. Sempre que possível, esses testes também foram executados no SPIM, um simulador MIPS gratuito, para garantir compatibilidade com implementações existentes da arquitetura. No entanto, não foi possível testar condições de exceção não padronizadas e interrupções, pois esses recursos não são implementados no SPIM.

Para verificar o funcionamento correto do processador em casos inesperados e extremos (*corner cases*), foram desenvolvidos dois geradores de testes direcionados aleatórios:

- um para a unidade de multiplicação/divisão (*multdiv*)
- outro para toda a CPU

Devido à complexidade algorítmica da unidade de multiplicação/divisão com algoritmo Booth radix-4 com sinal, decidiu-se testar o dispositivo de forma exaustiva utilizando um gerador de vetores de teste aleatórios. Esse gerador selecionava vetores de entrada a partir de um conjunto de casos conhecidos críticos, como:

- 1 e +1
- 0
- valores máximos e mínimos com sinal

5. Ferramentas de Sistema

Uma placa de desenvolvimento FPGA da Xilinx foi escolhida para emular a memória, fornecer dispositivos de E/S mapeados em memória (*memory-mapped I/O*) e gerar um sinal de clock em duas fases (*2-phase clock*). A Tabela I apresenta o mapa de memória do sistema de testes.

A memória de teste mapeia apenas os 17 bits inferiores para um endereço físico. Portanto, os 15 bits superiores são ignorados pelo sistema de memória externa. Durante o *reset*, o processador busca a instrução no endereço **0xBFC0 0000**, que por convenção corresponde ao vetor de reset, sendo mapeado para o endereço físico **0x000 0000**. Os três bits mais significativos do endereço são usados para contornar (*bypass*) o cache do chip, conforme descrito anteriormente.

---

**Tabela I — Mapa de memória do sistema de testes**

| Faixa de memória | Descrição |
| --- | --- |
| 0x000 0000 | Vetor de reset |
| 0x000 0004 | Vetor de exceção |
| 0x000 0100 – 0x000 01FC | Bootloader |
| 0x001 0200 – 0x001 6A7C | Memória de programa (ROM de instruções) |
| 0x001 6A80 – 0x004 3FFC | RAM de dados |
| 0x004 4000 | Array de LEDs |
| 0x004 4004 – 0x004 4010 | DIP switches |
| 0x004 4014 – 0x004 4024 | Botões |
| 0x004 4028 | Display LCD |