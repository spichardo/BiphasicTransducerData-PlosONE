function CalculatePowerVsPhase()
% This function process all the scale data to calculate effective power
% when applying the bi-axial method and the traditional method.
%Please refer to README.TXT for a description of the data files
close all;

TXs=dir('DL47*');

TxData=[];
for n=1:length(TXs)
    if ~isdir(TXs(n).name)
        continue
    end
    entry=ProcessTx(TXs(n).name,0); %0 to process the AVG experiments
    entry.name=TXs(n).name;
    TxData=[TxData;entry];
    
    entry=ProcessTx(TXs(n).name,1); % 1 to process the f1 experiments
    entry.name=TXs(n).name;
    TxData=[TxData;entry];
    
     entry=ProcessTx(TXs(n).name,2); % 2 to process the f2 experiments
    entry.name=TXs(n).name;
    TxData=[TxData;entry];
    
     entry=ProcessTx(TXs(n).name,3); % 3 to process the RES experiments
    entry.name=TXs(n).name;
    TxData=[TxData;entry];
    
    close all;
end

end


function TxMeas=ProcessTx(TxDir,TypeExp)
%TxDir indicates the directory where the data is located
%TypeExp indicates the type of "frequency" being tested
     CRITERIA_SEL_R2_EVAPORATION=0.9;
     TxMeas.LongOnly={};
     TxMeas.ShearLong={};
     InDir=dir( [ TxDir ,filesep ,'L*mat' ]);
     m=1;
     for n=1:length(InDir)
         if TypeExp==0 && ~isempty(strfind(InDir(n).name,'AVG'))
            SelDir(m)=  InDir(n);
            m=m+1;
            Suffix= '-AVG-';
         elseif TypeExp==1 && ~isempty(strfind(InDir(n).name,'f1'))
             SelDir(m)=  InDir(n);
              m=m+1;
             Suffix= '-F1-';
         elseif TypeExp==2 && ~isempty(strfind(InDir(n).name,'f2'))
             SelDir(m)=  InDir(n);
            m=m+1;
             Suffix= '-F2-';
         elseif TypeExp==3 &&   isempty(strfind(InDir(n).name,'AVG'))&&  isempty(strfind(InDir(n).name,'f1'))&&  isempty(strfind(InDir(n).name,'f2'))
            SelDir(m)=  InDir(n);
            m=m+1;
            Suffix= '-RES-';
         end
     end
     
     if ~exist('SelDir','var')
         return
     end
     
     
     
     %For each type of frequency tested, there should be 6 experiment
     %files, 3 per each modality tested (biaxial or traditional)
     %Data will processed in tandem to facilitate comparison
     
     if length(SelDir) ~=6
       error(['Number of total experiments must be 6:' ,TxDir])
     end
     
     ConcatAcPowerSL=[];
     ConcatAcPowerLong=[];
     
     ConcatEffectiveElecPowerSL_Long=[];
     ConcatEffectiveElecPowerSL_Shear=[];
     ConcatReflectedElecPowerSL_Long=[];
     ConcatReflectedElecPowerSL_Shear=[];
     
     ConcatEffectiveElecPowerLong_Long=[];
     ConcatEffectiveElecPowerLong_Shear=[];
     ConcatReflectedElecPowerLong_Long=[];
     ConcatReflectedElecPowerLong_Shear=[];
     
     CorrectedWeight=[];
     CorrectedR2=[];
     SelectedR2=logical([]);
     CorrectedR2Long=[];
     SelectedR2Long=logical([]);
     
     nLD=0;
     nSL=0;
     
     for n=1:length(SelDir)
         ExperimentFile= SelDir(n).name;

         if ~strncmp(ExperimentFile,'LS_',3) && ~strncmp(ExperimentFile,'L_D',3)
             error(['filename not using convention for experiment: ', sdir filesep ExperimentFile]);
         end
         sdir=TxDir;
         BaseData=load([sdir filesep ExperimentFile]);
         
         entry=CalculateForDataset(BaseData); %Here we calculate the acoustic power vs electrical power
         
         %from this point, data is concatenated for its processing in group
         if strncmp(ExperimentFile,'LS_',3)
             nSL=nSL+1;
             m=length(TxMeas.ShearLong);

             TxMeas.ShearLong{m+1}=entry;
             nReps=size(entry.AcousticPower,2);
             
             if (any(entry.AcousticPower<0))
                 msg =  ['WE HAVE ONLY ONE BAD WEIRD MEASUREMENT FOR FILE\n',...
                        TxDir,'/',ExperimentFile,'\n',...
                        'on phase 130 degrees the scale gave a strange negative reading\n',...
                        'we suspected this was caused by someone stepping to close to the scale\n',...
                        'this entry will be ignored in the processing'];
                   
                 fprintf(msg);
             end
             
             ConcatAcPowerSL=  [ConcatAcPowerSL,entry.AcousticPower];
             
           
            
             ConcatEffectiveElecPowerSL_Long=[ConcatEffectiveElecPowerSL_Long,repmat(entry.LongPower,1,nReps)];
             ConcatEffectiveElecPowerSL_Shear=[ConcatEffectiveElecPowerSL_Shear,repmat(entry.ShearPower,1,nReps)];
             ConcatReflectedElecPowerSL_Long=[ConcatReflectedElecPowerSL_Long,repmat(entry.ReflectedLongPower,1,nReps)];
             ConcatReflectedElecPowerSL_Shear=[ConcatReflectedElecPowerSL_Shear,repmat(entry.ReflectedShearPower,1,nReps)];
             CorrectedR2=    [CorrectedR2,repmat(entry.FittenesR2,1,nReps)];
             SelectedR2=     [SelectedR2,repmat(entry.FittenesR2>CRITERIA_SEL_R2_EVAPORATION,1,nReps)];
             
         else
             nLD=nLD+1;
             m=length(TxMeas.LongOnly);

             TxMeas.LongOnly{m+1}=entry;
             nReps=size(entry.AcousticPower,2);
             ConcatAcPowerLong=  [ConcatAcPowerLong,entry.AcousticPower];
             
             ConcatEffectiveElecPowerLong_Long=[ConcatEffectiveElecPowerLong_Long,repmat(entry.LongPower,1,nReps)];
             ConcatEffectiveElecPowerLong_Shear=[ConcatEffectiveElecPowerLong_Shear,repmat(entry.ShearPower,1,nReps)];
             ConcatReflectedElecPowerLong_Long= [ConcatReflectedElecPowerLong_Long,repmat(entry.ReflectedLongPower,1,nReps)];
             ConcatReflectedElecPowerLong_Shear=[ConcatReflectedElecPowerLong_Shear,repmat(entry.ReflectedShearPower,1,nReps)];
             
             
             CorrectedR2Long=    [CorrectedR2Long,repmat(entry.FittenesR2,1,nReps)];
             SelectedR2Long=     [SelectedR2Long,repmat(entry.FittenesR2>CRITERIA_SEL_R2_EVAPORATION,1,nReps)];
         end
             
     end
      ConcatElecPowerLong_L_Only = ConcatEffectiveElecPowerLong_Long+ ConcatEffectiveElecPowerLong_Shear;
        

        ConcatAcPowerSL(SelectedR2==0)=nan;
        ConcatElecPowerSL(SelectedR2==0)=nan;
        
        EfficiencySL=ConcatAcPowerSL./(ConcatEffectiveElecPowerSL_Long+ConcatEffectiveElecPowerSL_Shear);
        
        
        %As noted in line 120, we have one weird reading, we are suppressing from the data pool, this is the one abnormal reading
        %in the whole experiment dataset
        EfficiencySL(EfficiencySL<0)=nan;

        
        StdEffSL=nanstd(EfficiencySL,0,2);
        AvgEfficiencySL=nanmean(EfficiencySL,2);
        
        
        AvgAcPowerSL=nanmean(ConcatAcPowerSL,2);
        StdAcPowerSL=nanstd(ConcatAcPowerSL,0,2);
        
        
        ConcatAcPowerLong(SelectedR2Long==0)=nan;
        ConcatElecPowerLong_L_Only(SelectedR2Long==0)=nan;
        EfficiencyLong=ConcatAcPowerLong./ConcatElecPowerLong_L_Only;
        
        StdEffLong=nanstd(EfficiencyLong(:),0)*100;
        AvgEfficiencyLong=nanmean(EfficiencyLong(:))*100;
        
        
        AvgAcPowerLong=nanmean(ConcatAcPowerLong(:));
        StdAcPowerLong=nanstd(ConcatAcPowerLong(:),0);
        
       
        %%%%%%%%%%%%
        % This is constant value of dephase between the two amplifiers we
        % used
        DephaseAmp=42;
        
        TxMeas.ShearLong{1}.Phase=TxMeas.ShearLong{1}.Phase+DephaseAmp;
        
        TxMeas.ShearLong{1}.Phase(TxMeas.ShearLong{1}.Phase>360)=TxMeas.ShearLong{1}.Phase(TxMeas.ShearLong{1}.Phase>360)-360;
        
        [TxMeas.ShearLong{1}.Phase,indSortSL]=sort(TxMeas.ShearLong{1}.Phase);
        
        TxMeas.LongOnly{1}.Phase(TxMeas.LongOnly{1}.Phase>360)=TxMeas.LongOnly{1}.Phase(TxMeas.LongOnly{1}.Phase>360)-360;
         
        [TxMeas.LongOnly{1}.Phase,indsortLong]=sort(TxMeas.LongOnly{1}.Phase);
        
        AvgAcPowerSL=AvgAcPowerSL(indSortSL);
        StdAcPowerSL=StdAcPowerSL(indSortSL);
        AvgEfficiencySL=AvgEfficiencySL(indSortSL)*100;
        StdEffSL=StdEffSL(indSortSL)*100;
         
        
        ConcatEffectiveElecPowerSL_Long=ConcatEffectiveElecPowerSL_Long(indSortSL,:);
        ConcatEffectiveElecPowerSL_Shear=ConcatEffectiveElecPowerSL_Shear(indSortSL,:);
        ConcatReflectedElecPowerSL_Long=ConcatReflectedElecPowerSL_Long(indSortSL,:);
        ConcatReflectedElecPowerSL_Shear=ConcatReflectedElecPowerSL_Shear(indSortSL,:);
        
        ConcatEffectiveElecPowerLong_Long=ConcatEffectiveElecPowerLong_Long(indsortLong,:);
        ConcatEffectiveElecPowerLong_Shear=ConcatEffectiveElecPowerLong_Shear(indsortLong,:);
        ConcatReflectedElecPowerLong_Long=ConcatReflectedElecPowerLong_Long(indsortLong,:);
        ConcatReflectedElecPowerLong_Shear=ConcatReflectedElecPowerLong_Shear(indsortLong,:);
        
        
        [MaxEfficiency,MaxLocEfficiency]=max(AvgEfficiencySL);
        [MinEfficiency,MinLocEfficiency]=min(AvgEfficiencySL);
        
        disp([TxDir ,Suffix,' Max min Efficiency']);
        
        if TypeExp~=3
            PVector = [AvgEfficiencyLong,...
                MaxEfficiency,TxMeas.ShearLong{1}.Phase(MaxLocEfficiency),...
                AvgAcPowerSL(MaxLocEfficiency),...
                nanmean(ConcatEffectiveElecPowerSL_Long(MaxLocEfficiency,:)),...
                nanmean(ConcatEffectiveElecPowerSL_Shear(MaxLocEfficiency,:)),...
                MinEfficiency,TxMeas.ShearLong{1}.Phase(MinLocEfficiency),...
                AvgAcPowerSL(MinLocEfficiency),...
                nanmean(ConcatEffectiveElecPowerSL_Long(MinLocEfficiency,:)),...
                nanmean(ConcatEffectiveElecPowerSL_Shear(MinLocEfficiency,:))];
        else
            PVector = [AvgEfficiencyLong,...
                mean(AvgEfficiencySL),NaN,...
                mean(AvgAcPowerSL),...
                nanmean(ConcatEffectiveElecPowerSL_Long(:)),...
                nanmean(ConcatEffectiveElecPowerSL_Shear(:)),...
                mean(AvgEfficiencySL),NaN,...
                mean(AvgAcPowerSL),...
                 nanmean(ConcatEffectiveElecPowerSL_Long(:)),...
                nanmean(ConcatEffectiveElecPowerSL_Shear(:))];
        end
        fprintf('%3.2f & %3.2f & %3.0f & %3.2f & %3.2f & %3.2f & %3.2f & %3.0f & %3.2f & %3.2f & %3.2f\n' ,PVector);
        disp([TxDir ,Suffix,' Min max Ac power']);
        [MaxAcPower,MaxLocAcPower]=max(AvgAcPowerSL);
        [MinAcPower,MinLocAcPower]=min(AvgAcPowerSL);
        if TypeExp~=3
            PVector=[AvgAcPowerLong,...
                MaxAcPower,TxMeas.ShearLong{1}.Phase(MaxLocAcPower),...
                AvgEfficiencySL(MaxLocAcPower),...
                nanmean(ConcatEffectiveElecPowerSL_Long(MaxLocAcPower,:)),...
                nanmean(ConcatEffectiveElecPowerSL_Shear(MaxLocAcPower,:)),...
                MinAcPower,TxMeas.ShearLong{1}.Phase(MinLocAcPower),...
                AvgEfficiencySL(MinLocAcPower),...
                nanmean(ConcatEffectiveElecPowerSL_Long(MinLocAcPower,:)),...
                nanmean(ConcatEffectiveElecPowerSL_Shear(MinLocEfficiency,:))];
        else
            PVector=[AvgAcPowerLong,...
                mean(AvgAcPowerSL),NaN,...
                mean(AvgEfficiencySL),...
                nanmean(ConcatEffectiveElecPowerSL_Long(:)),...
                nanmean(ConcatEffectiveElecPowerSL_Shear(:)),...
                mean(AvgAcPowerSL),NaN,...
                mean(AvgEfficiencySL),...
                nanmean(ConcatEffectiveElecPowerSL_Long(:)),...
                nanmean(ConcatEffectiveElecPowerSL_Shear(:))];
        end
        fprintf('%3.2f & %3.2f & %3.0f & %3.2f & %3.2f & %3.2f & %3.2f & %3.0f & %3.2f & %3.2f & %3.2f\n' ,PVector);
        
        
        for k=1:2
        
            h=figure('visible','off');
          
            if k==2
                set(h,'Position',[1,1,560,1000]);
                subplot(3,1,1);
            end
            set(gca,'fontsize',14);
            errorbar(TxMeas.ShearLong{1}.Phase,AvgAcPowerSL,StdAcPowerSL,'-k','linewidth',1.5);

            ls=ones(length(TxMeas.LongOnly{1}.Phase),1);
            hold on;
            errorbar(TxMeas.LongOnly{1}.Phase,AvgAcPowerLong*ls,StdAcPowerLong*ls,':k','linewidth',1.5);

            xlim([0,360]);
            
            switch TxDir(1:2)
                    case 'T1'
                         ylim([0,0.15]);
                    case 'T2'
                         ylim([0,0.3]);
                    otherwise
                         ylim([0,0.15]);
                end
            
            if k==1

                
                set(gca,'XTick',[0,90,180,270,360])
                 set(gca,'XTickLabel',{'0','90','180','270','360'})
                 xlabel('$\phi$ ($^{\circ}$)','fontsize',16,'Interpreter','LaTex');
            end
            
            if (strcmp(TxDir(1:2),'T1') && k==2) || k==1
                ylabel('$W_A$ (W)','fontsize',16,'Interpreter','LaTex');
            end
            
            if k==1
                legend({'P+L','P'},'location','NorthWest');
                legend('boxoff')
                export_fig(gcf,['Figures/' TxDir Suffix 'AcPower.pdf'],'-transparent');
                export_fig(gcf,['Figures/' TxDir Suffix 'AcPower.eps']);

               h=figure('visible','off');
            else
                subplot(3,1,2);
            end
           set(gca,'fontsize',14);
           
            T=nanmean(ConcatEffectiveElecPowerSL_Shear+ConcatEffectiveElecPowerSL_Long,2);
            plot(TxMeas.ShearLong{1}.Phase,T,'-k','linewidth',1.5);
            hold on
            T=nanmean(ConcatEffectiveElecPowerSL_Long,2);
            plot(TxMeas.ShearLong{1}.Phase,T,':k','linewidth',1.5);
            hold on
           
             T=nanmean(ConcatEffectiveElecPowerSL_Shear,2);
            plot(TxMeas.ShearLong{1}.Phase,T,'--k','linewidth',1.5);
            
           
            
            switch TxDir(1:2)
                case 'T1'
                     ylim([0.75,2.5]);

                case 'T2'
                    ylim([0,3]);

                otherwise
                    if k==2
                        ylim([0.7,2.5]);
                    else
                        ylim([0,4]);
                    end
            end
            if k==2
                 tl=get(gca,'YTickLabel');
                 if ~iscell(tl)
                     tl=mat2cell(tl,ones(1,size(tl,1)),size(tl,2));
                 end                 
                 tl{length(tl)}='';
                 set(gca,'YTickLabel',tl);
            else
                set(gca,'XTick',[0,90,180,270,360])
                set(gca,'XTickLabel',{'0','90','180','270','360'})
                xlabel('$\phi$ ($^{\circ}$)','fontsize',16,'Interpreter','LaTex');
            end
            


           xlim([0,360]);

            if (strcmp(TxDir(1:2),'T1') && k==2) || k==1
                ylabel('$W_E$ (W)','fontsize',16,'Interpreter','LaTex');
            end

            if k==1
                legend({'P+L','P','L'},'location','North');
                legend('boxoff')
                export_fig(gcf,['Figures/' TxDir Suffix 'ElecPower.pdf'],'-transparent');
                export_fig(gcf,['Figures/' TxDir Suffix 'ElecPower.eps']);
                
                h=figure('visible','off');
                
                set(gca,'fontsize',14);
           
                 T=nanmean(ConcatEffectiveElecPowerSL_Long+ConcatReflectedElecPowerSL_Long,2);
                p(1)=plot(TxMeas.ShearLong{1}.Phase,T,':k^','linewidth',1.5);
                hold on
                
                T=nanmean(ConcatReflectedElecPowerSL_Long,2);
                p(2)=plot(TxMeas.ShearLong{1}.Phase,T,':ko','linewidth',1.5);
                hold on
                
                T=nanmean(ConcatEffectiveElecPowerSL_Long,2);
                p(3)=plot(TxMeas.ShearLong{1}.Phase,T,':ks','linewidth',1.5);
                hold on
                 

                 

                  T=nanmean(ConcatEffectiveElecPowerSL_Shear+ConcatReflectedElecPowerSL_Shear,2);
                p(4)=plot(TxMeas.ShearLong{1}.Phase,T,'--k^','linewidth',1.5);
                 hold on
                 
                  T=nanmean(ConcatReflectedElecPowerSL_Shear,2);
                p(5)=plot(TxMeas.ShearLong{1}.Phase,T,'--ko','linewidth',1.5);
                 hold on
                 
                T=nanmean(ConcatEffectiveElecPowerSL_Shear,2);
                p(6)=plot(TxMeas.ShearLong{1}.Phase,T,'--ks','linewidth',1.5);
                 hold on
                 
                 
                 legend({'$W_{F-P}$','$W_{R-P}$','$W_{E-P}$','$W_{F-L}$','$W_{R-L}$','$W_{E-L}$'},'location','NorthEastOutside','interpreter','latex');
                 legend('boxoff')
                 
                  xlim([0,360]);


                 ylabel('$W_E$ (W)','fontsize',16,'Interpreter','LaTex');
                  set(gca,'XTick',[0,90,180,270,360])
                set(gca,'XTickLabel',{'0','90','180','270','360'})
                xlabel('$\phi$ ($^{\circ}$)','fontsize',16,'Interpreter','LaTex');
                
                nummarkers(p,15);
                 export_fig(gcf,['Figures/' TxDir Suffix 'DetailElecPower.pdf'],'-transparent');
                 export_fig(gcf,['Figures/' TxDir Suffix 'DetailElecPower.eps']);
                 
               %%%%%%%%%%%%%%%%%%%
                h=figure('visible','off');;
                
                set(gca,'fontsize',14);
                

                 T=nanmean(ConcatEffectiveElecPowerLong_Long+ConcatReflectedElecPowerLong_Long,2);
                p(1)=plot(TxMeas.LongOnly{1}.Phase,T,':k^','linewidth',1.5);
                hold on
                
                T=nanmean(ConcatReflectedElecPowerLong_Long,2);
                p(2)=plot(TxMeas.LongOnly{1}.Phase,T,':ko','linewidth',1.5);
                hold on
                
                T=nanmean(ConcatEffectiveElecPowerLong_Long,2);
                p(3)=plot(TxMeas.LongOnly{1}.Phase,T,':ks','linewidth',1.5);
                hold on
                

                 

                  T=nanmean(ConcatEffectiveElecPowerLong_Shear+ConcatReflectedElecPowerLong_Shear,2);
                p(4)=plot(TxMeas.LongOnly{1}.Phase,T,'--k^','linewidth',1.5);
                 hold on
                 
                  T=nanmean(ConcatReflectedElecPowerLong_Shear,2);
                p(5)=plot(TxMeas.LongOnly{1}.Phase,T,'--ko','linewidth',1.5);
                 hold on
                 
                T=nanmean(ConcatEffectiveElecPowerLong_Shear,2);
                p(6)=plot(TxMeas.LongOnly{1}.Phase,T,'--ks','linewidth',1.5);
                 hold on
                 
                 
                 legend({'$W_{F-P}$','$W_{R-P}$','$W_{E-P}$','$W_{F-L}$','$W_{R-L}$','$W_{E-L}$'},'location','NorthEastOutside','interpreter','latex');
                 legend('boxoff')
                 
                  xlim([0,360]);


                 ylabel('$W_E$ (W)','fontsize',16,'Interpreter','LaTex');
                  set(gca,'XTick',[0,90,180,270,360])
                set(gca,'XTickLabel',{'0','90','180','270','360'})
                xlabel('$\phi$ ($^{\circ}$)','fontsize',16,'Interpreter','LaTex');
                
                yl=ylim;
                
                yl(2)=yl(2)+0.5;
                ylim(yl);
                
                nummarkers(p,15);
                 export_fig(gcf,['Figures/' TxDir Suffix 'LongOnlyDetailElecPower.pdf'],'-transparent');
                 export_fig(gcf,['Figures/' TxDir Suffix 'LongOnlyDetailElecPower.eps']);
                 
                 
               h=figure('visible','off');;
            else
                subplot(3,1,3);
            end
             set(gca,'fontsize',14);
            errorbar(TxMeas.ShearLong{1}.Phase,AvgEfficiencySL,StdEffSL,'k-','linewidth',1.5);
            hold on;
            ls=ones(length(TxMeas.LongOnly{1}.Phase),1);
            errorbar(TxMeas.LongOnly{1}.Phase,AvgEfficiencyLong*ls,StdEffLong*ls,':k','linewidth',1.5);

           xlim([0,360]);
           
           switch TxDir(1:2)
                case 'T1'
                     ylim([0,6.1]);
                case 'T2'
                     ylim([0,12]);
                otherwise
                     ylim([0,6.5]);
           end
               
           if k==2
               switch TxDir(1:2)
                    case 'T2'
                        
               end
           else
               set(gca,'XTick',[0,90,180,270,360])
            set(gca,'XTickLabel',{'0','90','180','270','360'})           
           end

            if k==2
                samexaxis('abc','xmt','on','ytac','join','yld',1);
            end

           set(gca,'XTick',[0,90,180,270,360])
            set(gca,'XTickLabel',{'0','90','180','270','360'})
            if (strcmp(TxDir(1:2),'T1') && k==2) || k==1
                ylabel('{\eta} (%)','fontsize',16,'Interpreter','Tex');
            end


            xlabel('$\phi$ ($^{\circ}$)','fontsize',16,'Interpreter','LaTex');
            
          
            if k==1
                legend({'P+L','P'},'location','NorthWest');
                legend('boxoff')
                export_fig(gcf,['Figures/' TxDir Suffix 'Efficiency.pdf'],'-transparent');
                export_fig(gcf,['Figures/' TxDir Suffix 'Efficiency.eps']);

            else
                  export_fig(gcf,['Figures/' TxDir Suffix '-AllCombined.pdf'],'-transparent');
                  export_fig(gcf,['Figures/' TxDir Suffix '-AllCombined.eps']);
            end
        end

        close all;
end

function Results=CalculateForDataset(BaseData)
    acquisition=BaseData.acquisition;

    Phase=zeros(length(acquisition),1);
    ShearPower=Phase;
    ReflectedShearPower=Phase;
    LongPower=Phase;
    ReflectedLongPower=Phase;
    AcousticPower=[];
    CorrectedWeight={};
    FittenesR2=Phase;

    SOS = SpeedofSoundWater(BaseData.TemperatureWater);

    for n =1:length(acquisition)
        
        [p,R2]=FitScaleEvaporation(acquisition(n).TimeVector_Pre_Measure,acquisition(n).MassVector_Pre_Measure);
        
        
        Phase(n)=acquisition(n).current_phase;
        ShearPower(n)=acquisition(n).Power_Shear;
        LongPower(n)=acquisition(n).Power_Longitudinal;
        ReflectedShearPower(n)=acquisition(n).Power_Shear_PowerB;
        ReflectedLongPower(n)=acquisition(n).Power_Longitudinal_PowerB;

        CorrectedWeight{n}=polyval(p,acquisition(n).TimeVector);
        FittenesR2(n)=R2;

        MeasuredMass=acquisition(n).current_mass;
        MeasuredMass=MeasuredMass-CorrectedWeight{n};
        

        AcousticPower(n,:)=(MeasuredMass(end))/1000*9.81*SOS;
    end

    [Phase,inds]=sort(Phase);
    Results.Phase=Phase;
    Results.ShearPower=ShearPower(inds);
    Results.LongPower=LongPower(inds);
    Results.ReflectedShearPower=ReflectedShearPower(inds);
    Results.ReflectedLongPower=ReflectedLongPower(inds);
    Results.AcousticPower=AcousticPower(inds,:);
    Results.CorrectedWeight=CorrectedWeight(inds);
    Results.FittenesR2=FittenesR2(inds);

end

function [p,R2]=FitScaleEvaporation(TimeVector_Pre_Measure,MassVector_Pre_Measure)
    p=polyfit(TimeVector_Pre_Measure,MassVector_Pre_Measure,1);
    
    yf = polyval(p,TimeVector_Pre_Measure);
    
    yresid = MassVector_Pre_Measure - yf;
    
    SSresid = sum(yresid.^2);
    
    SStotal = (length(MassVector_Pre_Measure)-1) * var(MassVector_Pre_Measure);
    
    R2 = 1 - SSresid/SStotal;
end

function y = nanstd(varargin)
%NANSTD Standard deviation, ignoring NaNs.
%   Y = NANSTD(X) returns the sample standard deviation of the values in X,
%   treating NaNs as missing values.  For a vector input, Y is the standard
%   deviation of the non-NaN elements of X.  For a matrix input, Y is a row
%   vector containing the standard deviation of the non-NaN elements in
%   each column of X. For N-D arrays, NANSTD operates along the first
%   non-singleton dimension of X.
%
%   NANSTD normalizes Y by (N-1), where N is the sample size.  This is the
%   square root of an unbiased estimator of the variance of the population
%   from which X is drawn, as long as X consists of independent, identically
%   distributed samples and data are missing at random.
%
%   Y = NANSTD(X,1) normalizes by N and produces the square root of the
%   second moment of the sample about its mean.  NANSTD(X,0) is the same as
%   NANSTD(X).
%
%   Y = NANSTD(X,FLAG,DIM) takes the standard deviation along dimension
%   DIM of X.
%
%   See also STD, NANVAR, NANMEAN, NANMEDIAN, NANMIN, NANMAX, NANSUM.

%   Copyright 1993-2006 The MathWorks, Inc.


% Call nanvar(x,flag,dim) with as many inputs as needed
y = sqrt(nanvar(varargin{:}));
end

function m = nanmean(x,dim)
%NANMEAN Mean value, ignoring NaNs.
%   M = NANMEAN(X) returns the sample mean of X, treating NaNs as missing
%   values.  For vector input, M is the mean value of the non-NaN elements
%   in X.  For matrix input, M is a row vector containing the mean value of
%   non-NaN elements in each column.  For N-D arrays, NANMEAN operates
%   along the first non-singleton dimension.
%
%   NANMEAN(X,DIM) takes the mean along dimension DIM of X.
%
%   See also MEAN, NANMEDIAN, NANSTD, NANVAR, NANMIN, NANMAX, NANSUM.

%   Copyright 1993-2004 The MathWorks, Inc.


% Find NaNs and set them to zero
nans = isnan(x);
x(nans) = 0;

if nargin == 1 % let sum deal with figuring out which dimension to use
    % Count up non-NaNs.
    n = sum(~nans);
    n(n==0) = NaN; % prevent divideByZero warnings
    % Sum up non-NaNs, and divide by the number of non-NaNs.
    m = sum(x) ./ n;
else
    % Count up non-NaNs.
    n = sum(~nans,dim);
    n(n==0) = NaN; % prevent divideByZero warnings
    % Sum up non-NaNs, and divide by the number of non-NaNs.
    m = sum(x,dim) ./ n;
end
end

function y = nanvar(x,w,dim)
if nargin < 2 || isempty(w), w = 0; end

sz = size(x);
if nargin < 3 || isempty(dim)
    % The output size for [] is a special case when DIM is not given.
    if isequal(x,[]), y = NaN(class(x)); return; end

    % Figure out which dimension sum will work along.
    dim = find(sz ~= 1, 1);
    if isempty(dim), dim = 1; end
elseif dim > length(sz)
    sz(end+1:dim) = 1;
end

% Need to tile the mean of X to center it.
tile = ones(size(sz));
tile(dim) = sz(dim);

if isequal(w,0) || isequal(w,1)
    % Count up non-NaNs.
    n = sum(~isnan(x),dim);

    if w == 0
        % The unbiased estimator: divide by (n-1).  Can't do this when
        % n == 0 or 1, so n==1 => we'll return zeros
        denom = max(n-1, 1);
    else
        % The biased estimator: divide by n.
        denom = n; % n==1 => we'll return zeros
    end
    denom(n==0) = NaN; % Make all NaNs return NaN, without a divideByZero warning

    x0 = x - repmat(nanmean(x, dim), tile);
    y = nansum(abs(x0).^2, dim) ./ denom; % abs guarantees a real result

% Weighted variance
elseif numel(w) ~= sz(dim)
    error(message('stats:nanvar:InvalidSizeWgts'));
elseif ~(isvector(w) && all(w(~isnan(w)) >= 0))
    error(message('stats:nanvar:InvalidWgts'));
else
    % Embed W in the right number of dims.  Then replicate it out along the
    % non-working dims to match X's size.
    wresize = ones(size(sz)); wresize(dim) = sz(dim);
    wtile = sz; wtile(dim) = 1;
    w = repmat(reshape(w, wresize), wtile);

    % Count up non-NaNs.
    n = nansum(~isnan(x).*w,dim);

    x0 = x - repmat(nansum(w.*x, dim) ./ n, tile);
    y = nansum(w .* abs(x0).^2, dim) ./ n; % abs guarantees a real result
end
end

function y = nansum(x,dim)
x(isnan(x)) = 0;
if nargin == 1 % let sum figure out which dimension to work along
    y = sum(x);
else           % work along the explicitly given dimension
    y = sum(x,dim);
end
end

function nummarkers(h,num)

% NUMMARKERS takes a vector of line handles in h
% and reduces the number of plot markers on the lines
% to num. This is useful for closely sampled data.
%
% example:
% t = 0:0.01:pi;
% p = plot(t,sin(t),'-*',t,cos(t),'r-o');
% nummarkers(p,10);
% legend('sin(t)','cos(t)')
%

% Magnus Sundberg Feb 08, 2001

for n = 1:length(h)
    if strcmp(get(h(n),'type'),'line')
        %axes(get(h(n),'parent'));
        x = get(h(n),'xdata');
        y = get(h(n),'ydata');
        t = 1:length(x);
        s = [0 cumsum(sqrt(diff(x).^2+diff(y).^2))];
        si = (0:num-1)*s(end)/(num-1);
        ti = round(interp1(s,t,si));
        ti=ti(~isnan(ti));
        xi = x(ti);
        yi = y(ti);
        marker = get(h(n),'marker');
        color = get(h(n),'color');
        style = get(h(n),'linestyle');
        % make a line with just the markers
        set(line(xi,yi),'marker',marker,'linestyle','none','color',color);
        % make a copy of the old line with no markers
        set(line(x,y),'marker','none','linestyle',style,'color',color);
        % set the x- and ydata of the old line to [], this tricks legend tokeep on working
        set(h(n),'xdata',[],'ydata',[]);
    end
end
end
