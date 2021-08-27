import React from "react";

const Residents = ({ residents, years }) => (
    <React.Fragment>
        {years.map(year => residents[year] && (
            <div key={year}>
                <h5>Families in {year}</h5>
                <table className="table table-condensed">
                    <thead>
                    <tr>
                        <th>Name</th>
                        <th>Relation</th>
                        <th>Age</th>
                        <th>Race</th>
                        <th>Sex</th>
                        <th>Occupation</th>
                    </tr>
                    </thead>
                    <tbody key={year}>
                    {residents[year].map(family => (
                        family.map(person => (
                            <tr key={person.id}>
                                <td><a href={`/census/${year}/${person.id}`}>{person.name}</a></td>
                                <td>{person.relation_to_head}</td>
                                <td>{person.age}</td>
                                <td>{person.race}</td>
                                <td>{person.sex}</td>
                                <td>{person.occupation}</td>
                            </tr>
                        ))
                    ))}
                    </tbody>
                </table>
            </div>
        ))}
    </React.Fragment>
)

export default Residents
