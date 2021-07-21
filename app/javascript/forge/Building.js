import React from 'react'
import {connect} from "react-redux";
import SimpleFormat from './SimpleFormat'

class Building extends React.PureComponent {
    render() {
        if (this.props.attributes) {
            const building = this.props.attributes
            return (
                <div id="building-details">
                    <h3>Building Details</h3>
                    <h5>
                        <a href={`/buildings/${ building.id }`} target="_blank"
                           title="Open building record in new tab">
                            <SimpleFormat text={building.street_address} />
                        </a>
                    </h5>

                    {(building.year_earliest || building.year_latest) && (
                        <dl className="mb-0">
                            <dt>Years</dt>
                            <dd>
                                {building.year_earliest && `Built in ${building.year_earliest}.`}
                                {building.year_latest ? ` Torn down in ${building.year_latest}.` : ' Still standing.'}
                            </dd>
                        </dl>
                    )}
                    {building.architects && building.architects.length && (
                        <dl className="mb-0">
                            <dt>Architects</dt>
                            <dd>{building.architects.map(architect => architect.name).join(', ')}</dd>
                        </dl>
                    )}
                    <dl>
                        <dt>Type</dt>
                        <dd>{building.type || 'Not specified'}</dd>
                        <dt>Construction</dt>
                        <dd>
                            {building.stories && `${building.stories}-story `}
                            {building.frame && `${building.frame} structure`}
                            {building.lining && ` with ${building.lining} lining`}
                            {!building.stories && !building.frame && !building.lining && 'Not specified'}
                            .
                        </dd>
                    </dl>
                    {building.photo && (
                        <div>
                            <picture>
                                <source srcSet={`/photos/${building.photo}/15/phone.jpg`}
                                        media="(max-width:480px)"/>
                                <source srcSet={`/photos/${building.photo}/15/tablet.jpg`}
                                        media="(min-width:481px) and (max-width:1024px)"/>
                                <source srcSet={`/photos/${building.photo}/15/desktop.jpg`}
                                        media="(min-width:1025px)"/>
                                <img className="img-responsive img-thumbnail" alt="Building photo" />
                            </picture>
                        </div>
                    )}
                    {building.description && building.description.length && (
                        <SimpleFormat text={building.description} />
                    )}
                    {building.census_records && building.census_records !== {} && (
                        <div>
                            <table className="table table-condensed">
                                <thead>
                                <tr>
                                    <th>Year</th>
                                    <th>Name</th>
                                    <th>Age</th>
                                    <th>Race</th>
                                    <th>Sex</th>
                                </tr>
                                </thead>
                                {[1900, 1910, 1920, 1930, 1940].map(year => (
                                    <tbody key={year}>
                                    {building.census_records[year] && building.census_records[year].map(person => (
                                        <tr key={person.id}>
                                            <td>{year}</td>
                                            <td><a href={`/census/${year}/${person.id}`} target="_blank">{person.name}</a></td>
                                            <td>{person.age}</td>
                                            <td>{person.race}</td>
                                            <td>{person.sex}</td>
                                        </tr>
                                    ))}
                                    </tbody>
                                ))}
                            </table>
                        </div>
                    )}
                </div>
        )
        } else {
            return <p className="alert alert-info">Click on a dot to see who lived there.</p>
        }
    }
}

const mapStateToProps = state => {
    if (state.buildings.building) {
        return {...state.buildings.building}
    } else {
        return {}
    }
}

const actions = {
}

const Component = connect(mapStateToProps, actions)(Building)

export default Component
