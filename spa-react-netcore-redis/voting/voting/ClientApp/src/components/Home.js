import React, { Component } from 'react';

export class Home extends Component {
  displayName = Home.name

  constructor(props) {
    super(props);
    this.state = { beer_loading: true, beers: [] };
    this.incrementCounter = this.incrementCounter.bind(this);

    fetch('api/Vote/options')
      .then(response => response.json())
      .then(data => {
        this.setState({ beer_loading: false, beers: data });
      });
  }

  incrementCounter(index) {
    var beers = this.state.beers;
    if(index != null && beers != null && beers[index] != null){
      fetch('api/Vote/options/'+beers[index].name)
        .then(response => response.json())
        .then(data => {
          beers[index] = data
          this.setState({
            beer_loading: false, 
            beers: beers
          });
        });
    }
  }


  static renderBeersTable(beers, incrementFunction) {
    return (
        <table className='table'>
          <thead>
            <tr>
              <th>Name</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {beers.map((beer, index) =>
              <tr key={beer.name}>
                <td>{beer.name}</td>
                <td><button class="btn btn-xs btn-primary" onClick={() => incrementFunction(index)}>Vote {beer.currentCount}</button></td>
              </tr>
            )}
          </tbody>
        </table>
    );
  }


  render() {
    let beer_contents = this.state.beer_loading
      ? <p><em>Loading...</em></p>
      : Home.renderBeersTable(this.state.beers, this.incrementCounter);

    return (
      <div>
        <div>
          <h1>Favorite Beer</h1>
          <p>Simply click the buttons below to increment the favorite beverage counters.</p>
          {beer_contents}
        </div>
      </div>
    );
  }
}
