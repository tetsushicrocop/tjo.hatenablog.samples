function cGC_plain_R2012b(it,Mlag1,Mlag2)
%%
% it: �u�[�g�X�g���b�v�񐔁B2000�������Ώ\�������A�K�v��p�l�ɂ���ĕς���K�v����B

%%
% GUI�Ńt�@�C����ǂݍ��ށB
% �֋X��"rawadata"�Ƃ����z���ǂݍ��ނ��Ƃɂ����Ă���B
% ���D�݂ŕύX���ꂽ���B

[fname,pname]=uigetfile('*.mat','Input a name of the data file');
load(fname);

%%
% �擾�����f�[�^�z��𐮌`����B
% �����Ƃ��ăm�[�h�i�s�����j�~���n��f�[�^�i������j�̏����łȂ���
% ���̃c�[���{�b�N�X�͓����Ȃ��B

[nodesNum,length]=size(rawdata);
dat=zeros(nodesNum,length);

% �m�[�h���ƂɎ��n��f�[�^��z�ϊ��Ő��K������B

for n=1:nodesNum
    dat(n,:)=zscore(rawdata(n,:));
end;

%%
% �T�����O�ő�l��ݒ肷��B
% �S���n�񒷂̔�����蒷�����O�����肵��GCA�͖��Ӗ��Ȃ̂ŁA
% ����ȉ��̒l���w�肵�Ă����B
% 1�̓e�X�g�l�p�A2�̓u�[�g�X�g���b�v�W�{�p�B
% �K������������K�v�͂Ȃ����A��҂͑��œK���O���������Ȃ�B

% ���炩�̊�Ŏ����Ō��߂Ă��܂��Ă��ǂ����A
% ���ɒ��ڂ��邩�ɂ���Ă��ς���K�v������̂ŁA
% ���O�Ɏ���͂Ō��߂�ꂽ�����ǂ��Ǝv����B
% �Ȃ��AMlag1 > Mlag2�̕�������B
% �����_�����n��̍œK���O�͉��X�ɂ��Ă��Ȃ�Z���Ȃ�B

% Mlag1 = floor(length/2);
% Mlag2 = Mlag1;

%%

%%%%%%%%%%%%%%%%%%%%%%%%%
% �e�X�g�l�̌v�Z���[�`�� %
%%%%%%%%%%%%%%%%%%%%%%%%%

% 1) �܂��œK���O��cca_find_model_order�֐��ŎZ�o����B
% 2�ϐ��Ƃ��œK���O�̒l�ł���ABIC��AIC�̒l���̂��̂ł͂Ȃ��_�ɒ��ӁB

[bic,aic]=cca_find_model_order(dat,2,Mlag1);

% 2) ���ɕ΃O�����W���[���ʎw����cca_partialgc�֐��ŎZ�o����B
% �Ԓl�͍\���́B

[ret]=cca_granger_regress(dat,aic,1);

% 3) �\����ret�𕪉����ĕϐ��ɕۑ�����B
% *.gc�͈��ʐ��O���t�}�g���N�X�A*.fg�͈��ʐ��w�����x(logF)�A
% *.doifg�͈��ʐ��w�����x�̂���Ƀm�[�h�ԑ��ݍ�(difference of influence)�B
% �ŋ߂̌����ł͂���DOI���ł��M�����������Ƃ���Ă���B

gcv=ret.gc;fsv=ret.fs;div=ret.doi;
gcv(isnan(gcv)==1)=0;
fsv(isnan(fsv)==1)=0;
div(isnan(div)==1)=0;
    
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �u�[�g�X�g���b�v�W�{�̌v�Z���[�`�� %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% �u�[�g�X�g���b�v�W�{�͌�Ńe�X�g�l�Ə��ʘa����Ŕ�r����̂ŁA
% �z��ł͂Ȃ��Z���Ƃ��ĕۑ�����B

    for i=1:it % it��u�[�g�X�g���b�v�v�Z
        bdat=zeros(nodesNum,length); % �u�[�g�X�g���b�v�E�����_���f�[�^�̂���
        seqb=zeros(nodesNum,length); % �����_�������ꂽ���n��C���f�b�N�X�̂��ƁB���e�����i�̕����x�^�[�B
        for r=1:nodesNum
            seqb(r,:)=randperm(length); % �܂����n��C���f�b�N�X�������_���\�[�g����B�m�[�h���Ƃɍ��B
        end;
        for r=1:nodesNum
            for j=1:length
                bdat(r,j)=dat(r,seqb(r,j)); % �m�[�h���ƂɃf�[�^���n����o���o���ɂ��ău�[�g�X�g���b�v�W�{�����B
            end;
        end;
    
% ��̓e�X�g�l�̎��Ɠ����悤�Ɍv�Z���邾���B

        [bicb,aicb]=cca_find_model_order(bdat,1,Mlag2);
        [bret]=cca_granger_regress(bdat,aicb,1);
        x1=bret.gc;x2=bret.fs;x3=bret.doi;
        x1(isnan(x1)==1)=0;
        x2(isnan(x2)==1)=0;
        x3(isnan(x3)==1)=0;
        gcbv{i}=x1;fsbv{i}=x2;dibv{i}=x3;
        fprintf(1,'\n�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@bootstrap %d AIC %f\n\n',i,aicb);
    end;

%%    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �u�[�g�X�g���b�v���v�l�̎Z�o %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ����������̂�fs(=*.fg)��doi(=*.doifg)�����Ȃ̂ŁA
% ����2�̃[���z�������Ă����B

    tmpfs=zeros(nodesNum,nodesNum);
    tmpdoi=zeros(nodesNum,nodesNum);

% ���������GC�}�g���N�X�z��̊e�v�f���Ƃɓ��v�l���v�Z����B
    
    for i=1:nodesNum
        for j=1:nodesNum
            btfs=[];btdoi=[]; % �u�[�g�X�g���b�v�W�{���Z�̏���
            for k=1:it % �����Ŗc��ȃu�[�g�X�g���b�v�W�{��A��������
                btfs=[btfs;fsbv{k}(i,j)];
                btdoi=[btdoi;dibv{k}(i,j)];
            end;
            % �A�����ꂽ�u�[�g�X�g���b�v�W�{�ƃe�X�g�l�Ƃ̓��v�I���ق�
            % ���ʘa����ŕ]������B
            % stats��z�l������̂ŁA�����p�l�̑���Ƃ���B
            [p,h,stats1]=ranksum(fsv(i,j),btfs);
            [p,h,stats2]=ranksum(div(i,j),btdoi);
            % z�l��stats�e�[�u�����甲���Ă��ĕۑ�����B
            tmpfs(i,j)=stats1.zval;
            tmpdoi(i,j)=stats2.zval;
        end;
    end;
    zfs=tmpfs;
    zdoi=tmpdoi;

%%
% ����ꂽz�l��z��Ƃ��ĕۑ����A�t�@�C���ɏo�͂��ďI���B
save gcdata_computed.mat gcv fsv div zfs zdoi bic aic;
end