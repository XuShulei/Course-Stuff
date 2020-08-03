#include <iostream>
#include <fstream>
#include <vector>
#include <cmath>
#include <cstdlib>

using namespace std;

vector<double> vec_price;
vector<double> vec_sqft;
int cnt=0;
double w0, w1, alpha=0.0000000001, epsilon=0.0000000001;

void getError(double w0, double w1) {
    double err=0;
    for (int i=0 ; i<cnt; i++) {
        err += abs(vec_price[i] - w1*vec_sqft[i]-w0);
    }
    cout<<"Error: "<<err<<endl<<endl;
}

void stochastic_gradient_descent(double w0, double w1) {
    double w0_error=epsilon+1, w1_error=epsilon+1;
    // Start Stochastic Gradient Descent at the obtained [w0,w1] plus [100,100]
    double w0_new = w0+100, w0_old = w0_new;
    double w1_new = w1+100, w1_old = w1_new;
    int iter=0, nUpdates=0, i, curr_cnt;
    double price, sqft;
    double w0_diff, w1_diff;
    while ( w0_error > epsilon && w1_error > epsilon) {
        w0_diff=0;
        w1_diff=0;
        i = rand() % cnt;
        price = vec_price[i];
        sqft = vec_sqft[i];
        // Compute the difference of [w0,w1] for the selected traning data
        w0_diff += (price - (w1_new * sqft + w0_new));
        w1_diff += ((price - (w1_new * sqft + w0_new))*sqft);
        // Update w0 and w1
        w0_new = w0_old + alpha * w0_diff;
        w1_new = w1_old + alpha * w1_diff;
        // Update error
        w0_error = abs(w0_new - w0_old);
        w1_error = abs(w1_new - w1_old);
        // Update old w0, w1 for next iteration
        w0_old = w0_new;
        w1_old = w1_new;
        iter++;
    }
    cout<<"Results after Stochastic Gradient descent, with epsilon "<<epsilon<<", alpha "<<alpha<<" : "<<endl
        <<"w0 = "<<w0_new<<", w1= "<<w1_new<<endl
        <<"Took "<<iter<<" iterations"<<endl;
    w0 = w0_new;
    w1 = w1_new;
    getError(w0,w1);
}

void gradient_descent(double w0, double w1, double w2) {
    //for ( alpha=0.0000000000001 ; alpha <= 0.1; alpha*=10) {
    //for ( epsilon=0.1 ; epsilon >= 0.0000000000001 ; epsilon/=10) {
    epsilon=alpha*10;
    double w0_error=epsilon+1, w1_error=epsilon+1, w2_error=epsilon+1;
    // Start Gradient Descent at the obtained [w0,w1] plus [100,100]
    double w0_new = w0+100, w0_old = w0_new;
    double w1_new = w1+100, w1_old = w1_new;
    double w2_new = w2, w2_old = w2;
    int iter=0, i, nUpdates=0;
    double price, sqft;
    double w0_diff, w1_diff, w2_diff;
    while ( w0_error > epsilon && w1_error > epsilon ) {// && w2_error > epsilon) {
        w0_diff=0;
        w1_diff=0;
        w2_diff=0;
        for (i=0 ; i<cnt; i++) {
            price = vec_price[i];
            sqft = vec_sqft[i];
            // Compute the difference of [w0,w1] for all traning data
            w0_diff += (price - (w2_new*sqft*sqft + w1_new * sqft + w0_new));
            w1_diff += ((price - (w2_new*sqft*sqft + w1_new * sqft + w0_new))*sqft);
            //w2_diff += ((price - (w2_new*sqft*sqft + w1_new * sqft + w0_new))*sqft*2);
            nUpdates++;
        }
        // Update w0 and w1
        w0_new = w0_old + alpha * w0_diff;
        w1_new = w1_old + alpha * w1_diff;
        w2_new = w2_old + alpha * w2_diff;
        // Update error
        w0_error = abs(w0_new - w0_old);
        w1_error = abs(w1_new - w1_old);
        w2_error = abs(w2_new - w2_old);
        // Update old w0, w1 for next iteration
        w0_old = w0_new;
        w1_old = w1_new;
        w2_old = w2_new;
        iter++;
    }
    cout<<"Results after Gradient descent, with epsilon "<<epsilon<<", alpha "<<alpha<<" : "<<endl
        <<"w0 = "<<w0_new<<", w1= "<<w1_new<<", w2= "<<w2<<endl
        <<"Took "<<iter<<" iterations, update "<<nUpdates<<" times"<<endl;
    w0 = w0_new;
    w1 = w1_new;
    getError(w0,w1);
    //}
}

int main(int argc, char ** argv) {
    ifstream input(argv[1]);
    double price, sqft;
    double sum_price=0, sum_sqft=0;
    double max_price=0, min_price=-1, max_sqft=0, min_sqft=-1;
    double sd_price=0, sd_sqft=0;
    while ( input >> price >> sqft) {
        sum_price += price;
        sum_sqft += sqft;
        if (price > max_price)
            max_price = price;
        if (price < min_price || min_price==-1)
            min_price = price;
        if (sqft > max_sqft)
            max_sqft = sqft;
        if (price < min_sqft || min_sqft==-1)        
            min_sqft = sqft;
        //cout<<price<<" "<<sqft<<endl;
        cnt++;
        vec_price.push_back(price);
        vec_sqft.push_back(sqft);
    }
    input.close();
    double mean_price=(double)(sum_price/cnt), mean_sqft=(double)(sum_sqft/cnt);
    double sum_sq_price=0, sum_sq_sqft=0, sum_price_times_sqft=0;
    for (int i=0 ; i<cnt; i++) {
        price = vec_price[i];
        sqft = vec_sqft[i];
        // Compute some values for later use to compute [w0,w1]
        sum_price_times_sqft += (price*sqft);
        sum_sq_price += (price*price);
        sum_sq_sqft += (sqft*sqft);
        //Compute standard deviation
        price -= mean_price;
        sqft -= mean_sqft;
        sd_price += (price*price);
        sd_sqft += (sqft*sqft);
    }
    sd_price = sqrt(sd_price/mean_price);
    sd_sqft = sqrt(sd_sqft/mean_sqft);
    cout<<"Mean: "<<mean_price<<", "<<mean_sqft<<endl;
    cout<<"Min: "<<min_price<<", "<<min_sqft<<endl;
    cout<<"Max: "<<max_price<<", "<<max_sqft<<endl;
    cout<<"Standard Deviation: "<<sd_price<<", "<<sd_sqft<<endl;
    //Compute coefficients w0 and w1 for the linear regresion 
    w1 = (cnt*sum_price_times_sqft - sum_price*sum_sqft) / (cnt*sum_sq_sqft - sum_sqft*sum_sqft);
    w0 = (sum_price - w1*sum_sqft )/cnt;
    cout<<"w0 = "<<w0<<", w1= "<<w1<<endl;
    getError(w0,w1);
    gradient_descent(w0,w1,0);
    stochastic_gradient_descent(w0,w1);
    return 0;
}
