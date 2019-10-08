#include <vector>

using namespace std;

struct plotter {
    vector<vector<TH1D*>> NPak4, NPak7;

    void loadData() {
        vector<TString> names = {"QCD_Pt-15to7000_TuneCP5_Flat_13TeV_pythia8"};

        for( auto n : names) {
            TFile *f = TFile::Open("../farm/"+n+"_Had/"+n+"_Had.root");
            cout << "../farm/"+n+"_Had/"+n+"_Had.root" << endl;
            TFile *fNoHad = TFile::Open("../farm/"+n+"_noHad/"+n+"_noHad.root");

            for(int R : vector<int>({4, 7})) {
                //cout << R << endl;
                vector<TH1D*> NPak4n, NPak7n;
                for(int y = 0; y < 4; ++y) {
                    TH1D *h      = (TH1D*) f->Get(Form("CMS_2019_incJets/ak%d_y%d",R,y));
                    TH1D *hNoHad = (TH1D*) fNoHad->Get(Form("CMS_2019_incJets/ak%d_y%d",R,y));
                    if(!hNoHad) {
                        cout << "Radek " << hNoHad << endl;
                        exit(1);
                    }
                    h->Divide(hNoHad);
                    if(R == 4) NPak4n.push_back(h);
                    else       NPak7n.push_back(h);
                }
                if(R == 4)  NPak4.push_back(NPak4n);
                else        NPak7.push_back(NPak7n);
            }
        }
    }

    void plotNP() {
        gStyle->SetOptStat(0);
        int y = 2;
        NPak4[0][y]->Draw("hist ][ ");
        NPak7[0][y]->SetLineColor(kRed);
        NPak7[0][y]->Draw("hist ][ same");


        gPad->SetLogx();
        gPad->BuildLegend();
    }

};

void plotNP()
{

    plotter pl;
    pl.loadData();
    pl.plotNP();






}
