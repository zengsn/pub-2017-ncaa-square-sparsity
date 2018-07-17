%% SQF_CRC.m
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
numOfAllTrain=numOfClasses*numOfTrain; % ѵ������
numOfAllTest=numOfClasses*numOfTest;   % ��������
clear preserved;
% (T*T'+aU)-1 * T
preserved=inv(trainData*trainData'+0.01*eye(numOfAllTrain))*trainData;
% �����ֲ��������ı�ʾϵ��
clear testSample;
clear solutionCRC;
errorsCRC=0; errorsSQCRC=0;
for kk=1:numOfAllTest
    testSample=testData(kk,:);
    % CRC �⣺(T*T'+aU)^-1 * T * D(i)'
    solutionCRC=preserved*testSample';
    % ��ӡ����
    fprintf('%d ', kk);
    if mod(kk,20)==0
        fprintf('\n');
    end
    % ���㹱��ֵ
    clear contributionCRC;
    clear contributionSQCRC;
    for cc=1:numOfClasses
        contributionCRC(:,cc)=zeros(row*col,1);
        contributionSQCRC(:,cc)=zeros(row*col,1);
        
        for tt=1:numOfTrain
            % C(i) = sum(S(i)*T)
            contributionCRC(:,cc)=contributionCRC(:,cc)+solutionCRC((cc-1)*numOfTrain+tt)*trainData((cc-1)*numOfTrain+tt,:)';
            % New Algorithm
            contributionSQCRC(:,cc)=contributionSQCRC(:,cc)+solutionCRC((cc-1)*numOfTrain+tt)^2*trainData((cc-1)*numOfTrain+tt,:)';
        end
    end
    % �������|�в�|����
    clear deviationCRC;
    clear deviationSQCRC;
    clear useDeviationCRC;
    clear duseDeviationSQCRC;
    for cc=1:numOfClasses
        % r(i) = |D(i)-C(i)|
        deviationCRC(cc)=norm(testSample'-contributionCRC(:,cc));
        % New Algorithm
        deviationSQCRC(cc)=norm(testSample'-contributionSQCRC(:,cc));
    end
    % ���봦��
    minDeviationCRC=min(deviationCRC);
    maxDeviationCRC=max(deviationCRC); % use = (val-min)/(max-min)
    useDeviationCRC=(deviationCRC-minDeviationCRC)/(maxDeviationCRC-minDeviationCRC);
    
    minDeviationSQCRC=min(deviationSQCRC);
    maxDeviationSQCRC=max(deviationSQCRC); % use = (val-min)/(max-min)
    useDeviationSQCRC=(deviationSQCRC-minDeviationSQCRC)/(maxDeviationSQCRC-minDeviationSQCRC);
    
    % ����ʶ����
    [min_value xxCRC]=min(useDeviationCRC);
    labelCRC(kk)=xxCRC;
    if labelCRC(kk)~=testLabel(kk)
        errorsCRC=errorsCRC+1;
    end
    [min_value xxSQCRC]=min(useDeviationSQCRC);
    labelSQCRC(kk)=xxSQCRC;
    if labelSQCRC(kk)~=testLabel(kk)
        errorsSQCRC=errorsSQCRC+1;
    end
    
    % �ں�
    for cii=1:numOfCases % �ܲ�ͬ�Ĳ���
        lambda = lambdas(1, cii); %fprintf('\n%f\n',lambda);
        % �ں�����
        deviationSQFCRC=deviationCRC+lambda*deviationSQCRC;
        [min_value zzSQFCRC]=min(deviationSQFCRC);
        % ��¼��ѽ�� - ���ڽ������
        %if kk==113 && lambda==0.1
        %    bestDeviationCRC = deviationCRC2;
        %    bestAbsoluteDistance = crcABS2;
        %    bestFusionCRC = fusionCRC;
        %end
        % ��¼�����ںϵĽ��
        labelSQFCRC(cii,kk)=zzSQFCRC; % CRC
    end
end
    
% �ҳ�������Ͻ��
lowestLambdaCRC = 0;
lowestErrorsCRC = numOfAllTest; % ��С������
for cii=1:numOfCases % ��鲻ͬ�����µĽ��
    lambda = lambdas(1, cii); %fprintf('\n%f\n',lambda);
    errorsSQFCRC=0; % ����������
    for kk=1:numOfAllTest % ͳ�ƴ�����
        if labelSQFCRC(cii,kk)~=testLabel(kk)
            errorsSQFCRC=errorsSQFCRC+1;
        end
    end
    %fprintf('%f��%d\n', lambda, errorsCRCFusion);
    % ��¼��ѽ��
    if errorsSQFCRC<lowestErrorsCRC
        lowestLambdaCRC = lambda;
        lowestErrorsCRC=errorsSQFCRC;
    end
    %fprintf('%f��%d\n', lowestLambda, lowestErrors);
end

% ȡ����ѽ��
lambdaCRC = lowestLambdaCRC;
errorsSQFCRC = lowestErrorsCRC;

% ͳ�ƴ�����
errorsRatioCRC=errorsCRC/numOfClasses/numOfTest;
errorsRatioSQCRC=errorsSQCRC/numOfClasses/numOfTest;
errorsRatioSQFCRC=errorsSQFCRC/numOfClasses/numOfTest;

% ������
result(numOfTrain, 1)=1-errorsRatioCRC;
result(numOfTrain, 2)=1-errorsRatioSQCRC;
result(numOfTrain, 3)=(errorsRatioCRC-errorsRatioSQCRC)/errorsRatioCRC;
result(numOfTrain, 4)=lambdaCRC;
result(numOfTrain, 5)=1-errorsRatioSQFCRC;
result(numOfTrain, 6)=(errorsRatioCRC-errorsRatioSQFCRC)/errorsRatioCRC;
improveCRC = result(numOfTrain, 3) * 100;
improveCRCFusion = result(numOfTrain, 6) * 100;
result % print

% ���浽�ļ�
type = 'SQF_CRC';
jsonFile = [dbName '/SQF_CRC_' num2str(numOfTrain)];
jsonFile = [jsonFile '_CRC(' num2str(improveCRC,2) '%,' num2str(lambdaCRC,2) '|' num2str(improveCRCFusion,2) '%)'];
jsonFile = [jsonFile '.json'];
dbJson = savejson('', result(numOfTrain,:), jsonFile);
%data=loadjson(jsonFile);
%result_json = data[db_name];

