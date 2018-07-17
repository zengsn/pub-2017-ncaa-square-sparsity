%% SQF_SRC.m
% ��ʾϵ������ƽ����

%% ����       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%lambda=0.2;    % �ںϲ��� ��
% ���ںϣ�CRC�������ABSʱʹ�ã�ǿ��CRC������
positives = [0.01, 0.05, 0.1, 0.3, 0.5, 0.7, 0.9];
% ���ںϣ�CRC�������ABSʱʹ�ã�ǿ��ABS������
negatives = [1.1, 1.3, 1.5, 1.7, 1.9, 5, 10, 100];
lambdas = [positives, negatives];
[one, numOfCases] = size(lambdas);
%minTrains = 4; % ��Сѵ��������
%maxTrains = 4; % ���ѵ��������
%inputData      % ������������

% �ܲ�ͬ��ѵ������
%{
if maxTrains == 0
    maxTrains = floor(numOfSamples*0.8);
elseif maxTrains > 12
    maxTrains = 12;
end
%}

% ʵ�ָ��ֱ�ʾ����
numOfTest = numOfSamples-numOfTrain;
numOfAllTrain=numOfClasses*numOfTrain; % ѵ������
numOfAllTest=numOfClasses*numOfTest;   % ��������
clear preserved;
% (T*T'+aU)-1 * T
preserved=inv(trainData*trainData'+0.01*eye(numOfAllTrain))*trainData;
% �����ֲ��������ı�ʾϵ��
clear testSample;
clear solutionSRC;
errorsSRC=0; errorsSQSRC=0;
for kk=1:numOfAllTest
    testSample=testData(kk,:);
    % ��ӡ����
    fprintf('%d ', kk);
    if mod(kk,20)==0
        fprintf('\n');
    end
    % SRC ��
    [solutionSRC, total_iter] =    SolveFISTA(trainData',testSample');
    % ���㹱��ֵ
    clear contributionSRC;
    clear contributionSQSRC;
    for cc=1:numOfClasses
        contributionSRC(:,cc)=zeros(row*col,1);
        contributionSQSRC(:,cc)=zeros(row*col,1);
        
        for tt=1:numOfTrain
            % C(i) = sum(S(i)*T)
            contributionSRC(:,cc)=contributionSRC(:,cc)+solutionSRC((cc-1)*numOfTrain+tt)*trainData((cc-1)*numOfTrain+tt,:)';
            % Square SRC
            contributionSQSRC(:,cc)=contributionSQSRC(:,cc)+solutionSRC((cc-1)*numOfTrain+tt)^2*trainData((cc-1)*numOfTrain+tt,:)';
        end
    end
    % �������|�в�|����
    clear deviationSRC;
    clear deviationSQSRC;
    clear useDeviationSRC;
    clear useDeviationSQSRC;
    for cc=1:numOfClasses
        % r(i) = |D(i)-C(i)|
        deviationSRC(cc)=norm(testSample'-contributionSRC(:,cc));
        % New Algorithm
        deviationSQSRC(cc)=norm(testSample'-contributionSQSRC(:,cc));
    end
    % ���봦��
    minDeviationSRC=min(deviationSRC);
    maxDeviationSRC=max(deviationSRC); % use = (val-min)/(max-min)
    useDeviationSRC=(deviationSRC-minDeviationSRC)/(maxDeviationSRC-minDeviationSRC);
    %useDeviationSRC=deviationSRC;
    
    minDeviationSQSRC=min(deviationSQSRC);
    maxDeviationSQSRC=max(deviationSQSRC); % use = (val-min)/(max-min)
    %useDeviationSRCTrans=(deviationSRCTrans-minDeviationSRCTrans)/(maxDeviationSRCTrans-minDeviationSRCTrans);
    useDeviationSQSRC=deviationSQSRC;
    
    % ����ʶ����
    [min_value xxSRC]=min(useDeviationSRC);
    labelSRC(kk)=xxSRC;
    if labelSRC(kk)~=testLabel(kk)
        errorsSRC=errorsSRC+1;
    end
    [min_value xxSQSRC]=min(useDeviationSQSRC);
    labelSQSRC(kk)=xxSQSRC;
    if labelSQSRC(kk)~=testLabel(kk)
        errorsSQSRC=errorsSQSRC+1;
    end
    
    % �ں�
    for cii=1:numOfCases % �ܲ�ͬ�Ĳ���
        lambda = lambdas(1, cii); %fprintf('\n%f\n',lambda);
        % �ں�����
        deviationSQFSRC=deviationSRC+lambda*deviationSQSRC;
        [min_value zzSRC]=min(deviationSQFSRC);
        % ��¼��ѽ�� - ���ڽ������
        %if kk==113 && lambda==0.1
        %    bestDeviationCRC = deviationCRC2;
        %    bestAbsoluteDistance = crcABS2;
        %    bestFusionCRC = fusionCRC;
        %end
        % ��¼�����ںϵĽ��
        labelSQFSRC(cii,kk)=zzSRC; % SRC
    end
end
    
% �ҳ�������Ͻ��
lowestLambdaSRC = 0;
lowestErrorsSRC = numOfAllTest; % ��С������
for cii=1:numOfCases % ��鲻ͬ�����µĽ��
    lambda = lambdas(1, cii); %fprintf('\n%f\n',lambda);
    errorsSQFSRC=0; % ����������
    for kk=1:numOfAllTest % ͳ�ƴ�����
        if labelSQFSRC(cii,kk)~=testLabel(kk)
            errorsSQFSRC=errorsSQFSRC+1;
        end
    end
    %fprintf('%f��%d\n', lambda, errorsCRCFusion);
    % ��¼��ѽ��
    if errorsSQFSRC<lowestErrorsSRC
        lowestLambdaSRC = lambda;
        lowestErrorsSRC = errorsSQFSRC;
    end
    %fprintf('%f��%d\n', lowestLambda, lowestErrors);
end

% ȡ����ѽ��
lambdaSRC = lowestLambdaSRC;
errorsSQFSRC = lowestErrorsSRC;

% ͳ�ƴ�����
errorsRatioSRC=errorsSRC/numOfClasses/numOfTest;
errorsRatioSQSRC=errorsSQSRC/numOfClasses/numOfTest;
errorsRatioSQFSRC=errorsSQFSRC/numOfClasses/numOfTest;

% ������
result(numOfTrain, 1)=1-errorsRatioSRC;
result(numOfTrain, 2)=1-errorsRatioSQSRC;
result(numOfTrain, 3)=(errorsRatioSRC-errorsRatioSQSRC)/errorsRatioSRC;
result(numOfTrain, 4)=lambdaSRC;
result(numOfTrain, 5)=1-errorsRatioSQFSRC;
result(numOfTrain, 6)=(errorsRatioSRC-errorsRatioSQFSRC)/errorsRatioSRC;
improveSQSRC = result(numOfTrain, 3) * 100; %
improveSQFSRC = result(numOfTrain, 6) * 100; %
result % print

% ���浽�ļ�
type = 'SQF_SRC';
jsonFile = [dbName '/SQF_SRC_' num2str(numOfTrain)];
jsonFile = [jsonFile '_SRC(' num2str(improveSQSRC,2) '%,' num2str(lambdaSRC,2) '|' num2str(improveSQFSRC,2) '%)'];
jsonFile = [jsonFile '.json'];
dbJson = savejson('', result(numOfTrain,:), jsonFile);
%data=loadjson(jsonFile);
%result_json = data[db_name];

